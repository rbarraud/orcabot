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

(defpackage #:orcabot-system (:use #:asdf #:cl))
(in-package #:orcabot-system)

#.(declaim (optimize (debug 3) (speed 0) (safety 3) (space 2)))

(defsystem orcabot
  :name "Orcabot"
  :version "2.0.0"
  :author "Daniel Lowe <dlowe@google.com>"
  :description "Orcabot IRC bot"
  :depends-on (cl+ssl cl-irc local-time iolib cl-ppcre html-entities drakma cxml)

  :components
  ((:module :src :components
            ((:file "defpackage")
             (:file "utils" :depends-on ("defpackage"))
             (:file "module" :depends-on ("utils"))
             (:file "admin" :depends-on ("module"))
             (:file "basic" :depends-on ("module"))
             (:file "bugzilla" :depends-on ("module"))
             (:file "chant" :depends-on ("module"))
             (:file "env" :depends-on ("module"))
             (:file "grammar" :depends-on ("module"))
             (:file "groups" :depends-on ("module"))
             (:file "karma" :depends-on ("module"))
             (:file "kittens" :depends-on ("module"))
             (:file "lastseen" :depends-on ("module"))
             (:file "logging" :depends-on ("module"))
             (:file "memo" :depends-on ("module"))
             (:file "parrot" :depends-on ("module"))
             (:file "quote" :depends-on ("module"))
             (:file "rt" :depends-on ("module"))
             (:file "stats" :depends-on ("module"))
             (:file "subversion" :depends-on ("module"))
             (:file "trivia" :depends-on ("module"))
             (:file "typist" :depends-on ("module"))
             (:file "werewolf" :depends-on ("module"))
             (:file "main" :depends-on ("module"))))))