;;; game.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; Developed with ML/AI assistance from Antigravity CLI & Gemini.
;;;
;;; Defines the CLOS class and ApplicationListener lifecycle methods for the rlgdx game.

(in-package #:rlgdx)

(defparameter *exit-on-close* t
  "The default value for the exit-on-close slot of newly instantiated rlgdx-game objects.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CLOS Game Class Definition

(defclass rlgdx-game ()
  ((batch
    :accessor game-batch
    :initform nil
    :documentation "The SpriteBatch used for drawing textures to the screen.")
   (texture
    :accessor game-texture
    :initform nil
    :documentation "The Texture representing the sprite image to draw.")
   (game-class
    :accessor game-class
    :initform nil
    :documentation "The dynamically created Java class representing the Game.")
   (game-instance
    :accessor game-instance
    :initform nil
    :documentation "The instance of the dynamically created Game class.")
   (exit-on-close
    :accessor game-exit-on-close
    :initarg :exit-on-close
    :initform *exit-on-close*
    :documentation "If non-nil, the application exits the JVM with status 0 upon disposal."))
  (:documentation "The CLOS class representing the libGDX game application state and listener."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generic Functions for ApplicationListener Lifecycle

(defgeneric gdx-create (game this)
  (:documentation "Called exactly once when the application is first created. Initializes resources."))

(defgeneric gdx-resize (game this width height)
  (:documentation "Called whenever the application window is resized."))

(defgeneric gdx-render (game this)
  (:documentation "Called repeatedly by the game loop to perform updates and rendering."))

(defgeneric gdx-pause (game this)
  (:documentation "Called when the application is paused or minimized."))

(defgeneric gdx-resume (game this)
  (:documentation "Called when the application regains focus after being paused."))

(defgeneric gdx-dispose (game this)
  (:documentation "Called when the application is destroyed to release assets."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Method Implementations for rlgdx-game

(defmethod gdx-create ((game rlgdx-game) this)
  "Initializes the graphics resources by loading the test sprite texture."
  (declare (ignore this))
  (format t "~&Initializing SpriteBatch and Texture...~%")
  (finish-output)
  (let* ((files (java:jfield "com.badlogic.gdx.Gdx" "files"))
         (file-handle (java:jcall "internal" files "assets/sprite.png")))
    (setf (game-batch game) (java:jnew "com.badlogic.gdx.graphics.g2d.SpriteBatch"))
    (setf (game-texture game) (java:jnew "com.badlogic.gdx.graphics.Texture" file-handle))
    (format t "~&Initialization complete. SpriteBatch and Texture loaded.~%")
    (finish-output)))

(defmethod gdx-resize ((game rlgdx-game) this width height)
  "Placeholder for handling window resizing events."
  (declare (ignore this width height))
  nil)

(defmethod gdx-render ((game rlgdx-game) this)
  "Checks for the escape key to quit, clears the graphics buffer, and renders the scaled sprite."
  (declare (ignore this))
  ;; 1. Check for exit input (ESCAPE)
  (let* ((input (java:jfield "com.badlogic.gdx.Gdx" "input"))
         (app (java:jfield "com.badlogic.gdx.Gdx" "app"))
         (escape-key (java:jfield "com.badlogic.gdx.Input$Keys" "ESCAPE")))
    (when (java:jcall "isKeyPressed" input escape-key)
      (format t "~&Escape key pressed. Exiting game...~%")
      (finish-output)
      (java:jcall "exit" app)
      (return-from gdx-render)))

  ;; 2. Clear screen to a dark charcoal color
  (let ((gl (java:jfield "com.badlogic.gdx.Gdx" "gl"))
        (mask (java:jfield "com.badlogic.gdx.graphics.GL20" "GL_COLOR_BUFFER_BIT")))
    (java:jcall "glClearColor" gl 0.15f0 0.15f0 0.15f0 1.0f0)
    (java:jcall "glClear" gl mask))

  ;; 3. Render the sprite scaled to half the smaller window dimension
  (let ((batch (game-batch game))
        (texture (game-texture game)))
    (when (and batch texture)
      (let* ((graphics (java:jfield "com.badlogic.gdx.Gdx" "graphics"))
             (w (coerce (java:jcall "getWidth" graphics) 'single-float))
             (h (coerce (java:jcall "getHeight" graphics) 'single-float))
             ;; Calculate target size as half of the smaller window dimension
             (target-size (/ (min w h) 2.0f0))
             (x (/ (- w target-size) 2.0f0))
             (y (/ (- h target-size) 2.0f0)))
        (java:jcall "begin" batch)
        (java:jcall "draw" batch texture x y target-size target-size)
        (java:jcall "end" batch)))))

(defmethod gdx-pause ((game rlgdx-game) this)
  "Placeholder for handling application pause events."
  (declare (ignore this))
  nil)

(defmethod gdx-resume ((game rlgdx-game) this)
  "Placeholder for handling application resume events."
  (declare (ignore this))
  nil)

(defmethod gdx-dispose ((game rlgdx-game) this)
  "Disposes of batch and texture assets to prevent memory leaks."
  (declare (ignore this))
  (format t "~&Disposing resources...~%")
  (finish-output)
  (let ((batch (game-batch game))
        (texture (game-texture game)))
    (when batch
      (java:jcall "dispose" batch)
      (setf (game-batch game) nil))
    (when texture
      (java:jcall "dispose" texture)
      (setf (game-texture game) nil)))
  (format t "~&Disposal complete.~%")
  (finish-output))
