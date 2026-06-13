;;; connect.lisp
;;;
;;; Connects to a running game instance via Swank.

(when (probe-file "vendor/bundle.lisp")
  (load "vendor/bundle.lisp"))

(unless (find-package :swank-client)
  (format t "Loading swank-client...~%")
  (asdf:load-system :swank-client))

(defun run-repl ()
  (swank-client:with-slime-connection (conn "localhost" 4005)
    (format t "Successfully connected to Swank server at localhost:4005.~%")
    (format t "Type Lisp expressions to evaluate them on the game server.~%")
    (format t "Type (quit) or press Ctrl-C to exit.~%")
    (loop
      (format t "~%SWANK> ")
      (finish-output)
      (let ((input (read-line *standard-input* nil :eof)))
        (when (eq input :eof) (return))
        (when (string-equal (string-trim " " input) "(quit)") (return))
        (unless (string-equal (string-trim " " input) "")
          (handler-case
              (let ((results (swank-client:slime-eval `(swank:eval-and-grab-output ,input) conn)))
                ;; results is a list: (output values-string)
                (let ((output (first results))
                      (values (second results)))
                  (when (and output (not (string= output "")))
                    (format t "~A" output))
                  (when (and values (not (string= values "")))
                    (format t "~A~%" values))))
            (error (e)
              (format t "Error: ~A~%" e))))))))

(run-repl)
