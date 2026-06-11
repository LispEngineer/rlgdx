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
  (format t "~&Disposal complete.~%")
  (when *exit-on-close*
    (ext:quit :status 0)))

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
        (setf *app* (java:jnew "com.badlogic.gdx.backends.lwjgl.LwjglApplication" *game-instance* config)))
      (format t "~&Finishing rlgdx...~%")
      0)))
