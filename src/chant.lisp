(in-package :orca)

(defvar *chants* (make-hash-table :test 'equalp))

(defun find-chantables (message)
  (let* ((text (cl-ppcre:split "\\s+"
                               (remove-if-not (lambda (c)
                                                (or (alphanumericp c)
                                                    (eql #\space c)))
                                              (second (arguments message)))))
         (signifier-pos (or (position "more" text :test 'string-equal)
                            (position "less" text :test 'string-equal)
                            (position "too" text :test 'string-equal)))
         (source (if (message-target-is-channel-p message)
                     (first (arguments message))
                     (source message))))
    (when (and signifier-pos
               (> (length text) (1+ signifier-pos)))
      (setf (gethash source *chants*)
            (format nil "~a ~a"
                    (elt text signifier-pos)
                    (elt text (1+ signifier-pos)))))))

(define-fun-command chant (message directp)
  (let* ((source (if (message-target-is-channel-p message)
                     (first (arguments message))
                     (source message)))
         (chant (gethash source *chants*)))
    (when chant
      (let ((msg (format nil "~a" (string-upcase chant))))
        (if (char= #\# (char (first (arguments message)) 0))
            (irc:privmsg (connection message) (first (arguments message)) msg)
            (irc:privmsg (connection message) (source message) msg))))))