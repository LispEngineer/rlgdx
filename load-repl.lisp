;; Do something like this: https://libgdx.com/wiki/jvm-langs/using-libgdx-with-clojure

(require :abcl-contrib)
(require :abcl-asdf)
(setf abcl-asdf:*mvn-libs-directory* #p"/usr/share/maven/lib/")
(abcl-asdf:ensure-mvn-version)
(push #p"/home/dfields/src/cl/abcl-libgdx/" asdf:*central-registry*)
(asdf:load-system :rlgdx)

(defparameter *my-game-class*
  ;; We need to save this, because it doesn't add the class to the system
  ;; class loader used by java:jnew
  (java:jnew-runtime-class
    "cc.dpf.rlgdx.Game"
    :superclass "com.badlogic.gdx.Game"
    :methods
    '(("create" :void () rlgdx-create))))

(defun rlgdx-create (this)
  (format t "My libGDX Game class is alive!~%"))

;; This works because you are passing the actual Class object, not a string.
(defparameter *game-instance* (java:jnew *my-game-class*))

;; Pass the *game-instance* into the application
(defparameter *app* (java:jnew "com.badlogic.gdx.backends.lwjgl.LwjglApplication" *game-instance*))