;;; update-dependencies.lisp
;;;
;;; Uses Quicklisp to download and vendor our project dependencies.
;;; This script is intended to be run manually or via `make vendor-deps`
;;; when project dependencies change. It is not required to run the game.

(let ((ql-setup (probe-file "~/quicklisp/setup.lisp")))
  (if ql-setup
      (load ql-setup)
      (error "Quicklisp not found at ~/quicklisp/setup.lisp. Please install Quicklisp to fetch dependencies.")))

(format t "Fetching dependencies and bundling into vendor/ directory...~%")
(ql:bundle-systems '(:alexandria) :to "vendor/")
(format t "Done! Dependencies are now vendored.~%")
(ext:quit)
