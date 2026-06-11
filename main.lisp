;;; main.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; Developed with ML/AI assistance from Antigravity CLI & Gemini.
;;;
;;; Core game logic and window initialization for the rlgdx game project.

(in-package #:rlgdx)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Globals

;; Define global parameters to hold game state resources.
(defparameter *batch* nil
  "The SpriteBatch used for drawing textures to the screen.")

(defparameter *texture* nil
  "The Texture representing the sprite image to draw.")

(defparameter *game-class* nil
  "The dynamically generated Java class representing the Game.")

(defparameter *game-instance* nil
  "The instance of the dynamically generated Game class.")

(defparameter *app* nil
  "The LwjglApplication instance running the game.")

(defparameter *exit-on-close* t
  "If non-nil, the application exits the JVM with status 0 upon disposal.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; libGDX Game class - basic implementation

(defun rlgdx-create (this)
  "Called when the game application is first created. Initializes the graphics and loads the texture."
  (declare (ignore this))
  (format t "~&Initializing SpriteBatch and Texture...~%")
  (let* ((files (java:jfield "com.badlogic.gdx.Gdx" "files"))
         (file-handle (java:jcall "internal" files "assets/sprite.png")))
    (setf *batch* (java:jnew "com.badlogic.gdx.graphics.g2d.SpriteBatch"))
    (setf *texture* (java:jnew "com.badlogic.gdx.graphics.Texture" file-handle))
    (format t "~&Initialization complete. SpriteBatch and Texture loaded.~%")))

(defun rlgdx-render (this)
  "Called on every frame. Checks for the ESC key to exit, clears the screen to charcoal, and renders the scaled sprite."
  (declare (ignore this))
  ;; 1. Check for exit input (ESC)
  (let* ((input (java:jfield "com.badlogic.gdx.Gdx" "input"))
         (app (java:jfield "com.badlogic.gdx.Gdx" "app"))
         (escape-key (java:jfield "com.badlogic.gdx.Input$Keys" "ESCAPE")))
    (when (java:jcall "isKeyPressed" input escape-key)
      (format t "~&Escape key pressed. Exiting game...~%")
      (java:jcall "exit" app)
      (return-from rlgdx-render)))

  ;; 2. Clear screen to a dark charcoal color
  (let ((gl (java:jfield "com.badlogic.gdx.Gdx" "gl"))
        (mask (java:jfield "com.badlogic.gdx.graphics.GL20" "GL_COLOR_BUFFER_BIT")))
    (java:jcall "glClearColor" gl 0.15f0 0.15f0 0.15f0 1.0f0)
    (java:jcall "glClear" gl mask))

  ;; 3. Render the sprite scaled to half the smaller window dimension
  (when (and *batch* *texture*)
    (let* ((graphics (java:jfield "com.badlogic.gdx.Gdx" "graphics"))
           (w (coerce (java:jcall "getWidth" graphics) 'single-float))
           (h (coerce (java:jcall "getHeight" graphics) 'single-float))
           ;; Calculate target size as half of the smaller window dimension
           (target-size (/ (min w h) 2.0f0))
           (x (/ (- w target-size) 2.0f0))
           (y (/ (- h target-size) 2.0f0)))
      (java:jcall "begin" *batch*)
      (java:jcall "draw" *batch* *texture* x y target-size target-size)
      (java:jcall "end" *batch*))))

(defun rlgdx-dispose (this)
  "Called when the game window is closed. Disposes of resources to prevent memory leaks."
  (declare (ignore this))
  (format t "~&Disposing resources...~%")
  (when *batch*
    (java:jcall "dispose" *batch*)
    (setf *batch* nil))
  (when *texture*
    (java:jcall "dispose" *texture*)
    (setf *texture* nil))
  (format t "~&Disposal complete.~%"))

(defun ensure-game-class ()
  "Ensures that the runtime Game class is defined."
  (unless *game-class*
    (setf *game-class*
      (java:jnew-runtime-class
        "cc.dpf.rlgdx.Game"
        :superclass "com.badlogic.gdx.ApplicationAdapter"
        :methods
        '(("create" :void () rlgdx-create)
          ("render" :void () rlgdx-render)
          ("dispose" :void () rlgdx-dispose))))))

;; This is necessary (well, not really necessary, but sorta kinda nice) because if you
;; just exit in the previous way (java:jstatic "exit" "java.lang.System" 0) the
;; audio library complains about incomplete cleanup. It says:
;;   Disposal complete.
;;   AL lib: (EE) alc_cleanup: 1 device not closed
;; I'm not convinced this is worth its complexity.
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

(defun main ()
  "Launches the rlgdx game. Executes tests first if '--test' is specified in command-line arguments."
  (if (member "--test" ext:*command-line-argument-list* :test #'string=)
    (let ((success (run-tests)))
      (ext:quit :status (if success 0 1)))
    (progn
      (format t "~&Starting rlgdx...~%")
      (ensure-game-class)
      (setf *game-instance* (java:jnew *game-class*))

      ;; Configure window title and size using LwjglApplicationConfiguration
      (let ((config (java:jnew "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration")))
        (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "title" config) "ABCL libGDX Roguelike PoC")
        (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "width" config) 1280)
        (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "height" config) 720)
        (setf (java:jfield "com.badlogic.gdx.backends.lwjgl.LwjglApplicationConfiguration" "forceExit" config) nil)
        ;; As soon as this LwjglApplication is created, the game will start and run in a background
        ;; thread called "LWJGL Application".
        (setf *app* (java:jnew "com.badlogic.gdx.backends.lwjgl.LwjglApplication" *game-instance* config))
        (when *exit-on-close*
          (join-lwjgl-thread)
          (format t "~&LWJGL thread terminated. Exiting JVM.~%")
          (ext:quit :status 0)))
      (format t "~&Finishing rlgdx...~%")
      0)))
