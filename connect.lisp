;;; connect.lisp
;;;
;;; Connects to a running game instance via Swank.

(when (probe-file "vendor/bundle.lisp")
  (load "vendor/bundle.lisp"))

(unless (find-package :swank-client)
  (format t "Loading swank-client...~%")
  (asdf:load-system :swank-client))

(format t "Connecting to game instance at localhost:4005...~%")
(swank-client:slime-repl "localhost" 4005)
