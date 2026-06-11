;;; load-repl.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; Make it easy to load everything into a clean new REPL instance

(require :abcl-contrib)
(require :abcl-asdf)
(setf abcl-asdf:*mvn-libs-directory* #p"/usr/share/maven/lib/")
(abcl-asdf:ensure-mvn-version)
(push #p"/home/dfields/src/cl/abcl-libgdx/" asdf:*central-registry*)
(asdf:load-system :rlgdx)

;; Do not close the game when we're running from REPL
(setf rlgdx:*exit-on-close* nil)
(in-package :rlgdx)

;; TODO: Prompt the user with how to instantiate and run the game.
(format t "Evaluate (main) or (rlgdx:main) to launch the game.")