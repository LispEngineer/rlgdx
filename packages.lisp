;;; packages.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; Package definitions for the rlgdx game project.

(defpackage #:rlgdx
  (:use #:cl)
  (:export 
    ;; Globals
    #:*app*
    #:*active-game*
    #:*game-instance*
    #:*exit-on-close*
    #:*enable-slynk*
    #:*slynk-port*
    
    ;; Entry Point
    #:main
    #:start-slynk-server
    #:slynk-running-p
    #:with-gl-thread

    ;; CLOS Class and Accessors
    #:rlgdx-game
    #:game-batch
    #:game-texture
    #:game-class
    #:game-instance
    #:game-exit-on-close))
