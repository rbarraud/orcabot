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

(defpackage #:orcabot
	(:use :common-lisp
          :local-time
          :irc
          :parse-number)
    (:import-from #:alexandria
                  #:alist-hash-table
                  #:hash-table-keys
                  #:hash-table-values
                  #:random-elt)
	(:export start-orcabot-session
             background-orcabot-session)
    (:local-nicknames (:log :com.ravenbrook.common-lisp-log)
                      (:re :cl-ppcre)))
