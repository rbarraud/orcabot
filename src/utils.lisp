;;; Copyright 2012 Daniel Lowe All Rights Reserved.
;;;
;;; Licensed under the Apache License, Version 2.0 (the "License");
;;; you may not use this file except in compliance with the License.
;;; You may obtain a copy of the License at
;;;
;;;     http://www.apache.org/licenses/LICENSE-2.0
;;;
;;; Unless required by applicable law or agreed to in writing, software
;;; distributed under the License is distributed on an "AS IS" BASIS,
;;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;; See the License for the specific language governing permissions and
;;; limitations under the License.

(in-package #:orcabot)

(defparameter *orcabot-root-pathname*
    (asdf:component-pathname (asdf:find-system "orcabot")))

(define-condition orcabot-exiting () ())
(define-condition no-such-module (error) ())

(defvar *command-funcs* (make-hash-table :test 'equalp))

(defun orcabot-path (fmt &rest args)
  "Returns the local pathname merged with the root package path."
  (let ((path (if args
                  (format nil "~?" fmt args)
                  fmt)))
    (merge-pathnames path *orcabot-root-pathname*)))

(defun join-string (delimiter list)
  (format nil (format nil "~~{~~a~~^~a~~}" delimiter) list))

(defun string-limit (str max-len)
  (string-trim '(#\space)
               (if (< (length str) max-len)
                   str
                   (let ((pivot (position-if-not #'alphanumericp
                                                 str
                                                 :from-end t
                                                 :end max-len)))
                     (concatenate 'string
                                  (subseq str 0 (or pivot max-len))
                                  "...")))))

(defun reply-to (message fmt &rest args)
  (let* ((raw-response (format nil "~?" fmt args))
         (raw-response-lines (ppcre:split "\\n" raw-response))
         (responses (mapcar (lambda (line)
                              (string-limit line 500))
                            raw-response-lines)))
    (cond
      ((char= #\# (char (first (arguments message)) 0))
       (dolist (line responses)
         (when (string/= line "")
           (irc:privmsg (connection message) (first (arguments message)) line))))
      (t
       (dolist (line responses)
         (when (string/= line "")
           (irc:privmsg (connection message) (source message) line)))))))

(defun authentication-credentials (host)
  (flet ((read-word (stream)
           (when (peek-char t stream nil)
             (with-output-to-string (s)
               (loop
                  for c = (read-char stream nil)
                  while (and c
                             (char/= c #\newline)
                             (char/= c #\space)) do
                    (princ c s))))))
    (let ((found-machine nil)
          (result nil))
      (with-open-file (inf (merge-pathnames (user-homedir-pathname)
                                            ".netrc")
                           :direction :input
                           :if-does-not-exist nil)
        (when inf
          (loop
             for key = (read-word inf)
             as val = (read-word inf)
             while val do
             (cond
               ((string-equal key "machine")
                (setf found-machine (string-equal val host)))
               (found-machine
                (push val result)
                (push (intern (string-upcase key) :keyword) result)))))
        result))))

(defun shorten-nick (full-nick)
  (ppcre:scan-to-strings "[A-Za-z]+" full-nick))

(defun normalize-nick (nick)
  "Remove trailing numbers and everything after an underscore or dash.
Used for comparing nicks for equality."
  (string-downcase (ppcre:regex-replace "(?:[-_].*|\\d+$)" nick "")))

(defun message-target-is-channel-p (message)
  (find (char (first (arguments message)) 0) "#+"))

(defun all-matches-register (regex target-string register
                             &key (start 0)
                             (end (length target-string))
                             (sharedp nil))
  (let ((substr-fn (if sharedp #'ppcre::nsubseq #'subseq))
        (result-list nil))
      (ppcre:do-scans (start end reg-start reg-end
                             regex target-string
                             result-list
                             :start start :end end)
        (push (funcall substr-fn
                       target-string
                       (aref reg-start register)
                       (aref reg-end register))
              result-list))))

(defun switch-person (str)
  (cl-ppcre:regex-replace-all
   (cl-ppcre:create-scanner "\\b(mine|me|my|I am|I'm|I|you are|you're|yours|your|you)\\b" :case-insensitive-mode t)
   str
   (lambda (target start end match-start match-end reg-starts reg-ends)
     (declare (ignore start end reg-starts reg-ends))
     (let ((match (make-array (list (- match-end match-start)) :element-type 'character :displaced-to target :displaced-index-offset match-start)))
       (cond
         ((string-equal "I" match)
          "you")
         ((string-equal "me" match)
          "you")
         ((string-equal "my" match)
          "your")
         ((string-equal "I am" match)
          "you are")
         ((string-equal "I'm" match)
          "you're")
         ((string-equal "mine" match)
          "yours")
         ((string-equal "you" match)
          "I")
         ((string-equal "your" match)
          "my")
         ((string-equal "yours" match)
          "mine")
         ((string-equal "you're" match)
          "I'm")
         ((string-equal "you are" match)
          "I am"))))))

(defun make-random-list (length max)
  "Generate a non-repeating list of random numbers of length LENGTH.  The maxim\
um value of the random numbers is MAX - 1."
  (declare (fixnum length max))
  (unless (plusp length)
    (error "LENGTH may not be negative."))
  (unless (plusp max)
    (error "Can't generate negative numbers."))
  (unless (<= length max)
    (error "Can't generate a non-repeating list when LENGTH > MAX"))
  (let ((unused (make-array max :element-type 'fixnum)))
    ;; create an array with each element set to its index
    (dotimes (idx max)
      (setf (aref unused idx) idx))
    ;; select a random index to pull from the array, then set the number
    ;; at the index to the last selectable element in the array.  Continue
    ;; until we have the requisite list length
    (loop for result-size from 0 upto (1- length)
          as num = (random (- max result-size))
          collect (aref unused num)
          do (setf (aref unused num) (aref unused (- max result-size 1))))))

(defun describe-duration (span)
  (cond
    ((>= span 86400)
     (format nil "~ad" (round span 86400)))
    ((>= span 3600)
     (format nil "~ah" (round span 3600)))
    ((>= span 60)
     (format nil "~am" (round span 60)))
    (t
     (format nil "~as" span))))
