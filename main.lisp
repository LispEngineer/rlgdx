;;; main.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; Developed with ML/AI assistance from Antigravity CLI & Gemini.
;;;
;;; Core game initialization and window adapter for the rlgdx project.

(in-package #:rlgdx)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Globals

(defparameter *app* nil
  "The LwjglApplication instance running the game.")

(defparameter *active-game* nil
  "The active CLOS game instance (an instance of rlgdx-game) for REPL access.")

(defparameter *game-instance* nil
  "The active Java game instance (an instance of cc.dpf.rlgdx.Game) for REPL access.")

(defparameter *game-class* nil
  "The dynamically generated Java class representing the Game.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Runtime Class Definitions

(defun ensure-game-class ()
  "Ensures that the runtime Game class extending com.badlogic.gdx.Game is defined.
   Stores the delegated CLOSGame reference in a public field and delegates all methods."
  (unless *game-class*
    (setf *game-class*
      (java:jnew-runtime-class
        "cc.dpf.rlgdx.Game"
        :superclass "com.badlogic.gdx.Game"
        :fields '(("CLOSGame" "org.armedbear.lisp.LispObject" :modifiers (:public)))
        :constructors '((("org.armedbear.lisp.LispObject")
                         (lambda (this clos-game)
                           (setf (java:jfield "CLOSGame" this) clos-game))))
        :methods
        `(("create" :void ()
           ,(lambda (this)
              (gdx-create (java:jfield "CLOSGame" this) this)))
          ("resize" :void (:int :int)
           ,(lambda (this w h)
              (gdx-resize (java:jfield "CLOSGame" this) this w h)))
          ("render" :void ()
           ,(lambda (this)
              (gdx-render (java:jfield "CLOSGame" this) this)))
          ("pause" :void ()
           ,(lambda (this)
              (gdx-pause (java:jfield "CLOSGame" this) this)))
          ("resume" :void ()
           ,(lambda (this)
              (gdx-resume (java:jfield "CLOSGame" this) this)))
          ("dispose" :void ()
           ,(lambda (this)
              (gdx-dispose (java:jfield "CLOSGame" this) this))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper Utilities

(defun join-lwjgl-thread ()
  "Locates the 'LWJGL Application' thread and joins it, waiting for it to terminate completely.
   It tries a few times to find the thread in case it hasn't yet started."
  (loop for attempt from 1 to 10
        do (let* ((active-count (java:jstatic "activeCount" "java.lang.Thread"))
                  (thread-array (java:jnew-array "java.lang.Thread" active-count))
                  (found-thread nil))
             (java:jstatic "enumerate" "java.lang.Thread" thread-array)
             (dotimes (i active-count)
               (let ((thr (java:jarray-ref thread-array i)))
                 (when (and thr
                            (string= (java:jcall "getName" thr) "LWJGL Application"))
                   (setf found-thread thr))))
             (if found-thread
                (progn
                  (format t "~&Waiting for LWJGL Application thread to terminate...~%")
                  (handler-case
                    (java:jcall "join" found-thread)
                    (error (e)
                      (format t "~&Error joining thread: ~A~%" e)))
                  (return))
                (sleep 0.1)))
        finally (format t "~&Warning: LWJGL Application thread not found.~%")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Entry Point

(defun main ()
  "Launches the rlgdx game application. Executes unit tests first if '--test' is provided."
  (if (member "--test" ext:*command-line-argument-list* :test #'string=)
    (let ((success (run-tests)))
      (ext:quit :status (if success 0 1)))
    (progn
      (format t "~&Starting rlgdx...~%")
      (finish-output)
      (ensure-game-class)
      
      (let* ((clos-game (make-instance 'rlgdx-game))
             (java-instance (java:jnew *game-class* clos-game)))
        
        ;; Save instances to globals for interactive debugging
        (setf *active-game* clos-game)
        (setf *game-instance* java-instance)
        
        (setf (game-class clos-game) *game-class*)
        (setf (game-instance clos-game) java-instance)

        ;; Configure window title and size using LwjglApplicationConfiguration
        (let ((config (java:jnew "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration")))
          (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "title" config)
                "ABCL libGDX Roguelike PoC")
          (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "width" config) 1280)
          (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "height" config) 720)
          ;; This prevents libGDX from exiting the program/JVM when the game instance exits.
          (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "forceExit" config) nil)
          ;; As soon as this LwjglApplication is created, the game will start and run in a background
          ;; thread called "LWJGL Application".
          (setf *app* (java:jnew "com.badlogic.gdx.backends.lwjgl.LwjglApplication" java-instance config))
          
          (when (game-exit-on-close clos-game)
            (join-lwjgl-thread)
            (format t "~&LWJGL thread terminated. Exiting JVM.~%")
            (finish-output)
            (ext:quit :status 0))))
      (format t "~&Finishing rlgdx...~%")
      (finish-output)
      0)))
