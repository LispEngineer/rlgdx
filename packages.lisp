;;; packages.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; Package definitions for the rlgdx game project.

(defpackage #:rlgdx
  (:use #:cl)
  (:export #:main
           #:rlgdx-create
           #:rlgdx-render
           #:rlgdx-dispose))
