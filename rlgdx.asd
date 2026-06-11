;;; packages.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; System definition for the Roguelike libGDX proof of concept.
;;; This is complex because we have to load some specific LibGDX
;;; libraries to get it to run on the desktop, using syntax that
;;; is not supported by default in the abcl-asdf Maven implementation,
;;; involving specifying specific classifiers for the necessary
;;; libGDX JARs from Maven. See :perform for details.
;;;
;;; It took quite a few tries to get this right on Linux.

;; Load the classified version of those dependencies above
(defsystem #:rlgdx
  :description "Roguelike Game Proof of Concept in ABCL with libGDX"
  :version "0.0.1"
  :defsystem-depends-on (#:abcl-asdf)  
  :components (
    (:mvn "com.badlogicgames.gdx/gdx" :version "1.14.2")
    (:mvn "com.badlogicgames.gdx/gdx-backend-lwjgl" :version "1.14.2")
    (:mvn "com.badlogicgames.gdx/gdx-box2d" :version "1.14.2")
    (:mvn "com.badlogicgames.gdx/gdx-bullet" :version "1.14.2")
    (:file "packages")
    (:file "game" :depends-on ("packages"))
    (:file "main" :depends-on ("game"))
    (:file "tests" :depends-on ("main"))
  )

;; Load the specific "classifier" specified versions of libGDX libraries.
:perform 
  (asdf:load-op :after (op c)
    (let ((natives '(;; Format: (group "artifact:packaging:classifier" version)
                     ("com.badlogicgames.gdx" "gdx-box2d-platform:jar:natives-desktop" "1.14.2")
                     ("com.badlogicgames.gdx" "gdx-bullet-platform:jar:natives-desktop" "1.14.2")
                     ("com.badlogicgames.gdx" "gdx-platform:jar:natives-desktop" "1.14.2"))))

      (dolist (coord natives)
        (let ((group (first coord))
              (artifact (second coord))
              (version (third coord)))

          (format t "~&Locating native binaries for: ~A:~A~%" group artifact)

          ;; 1. Use the official API function strictly with positional and keyword arguments
          (let ((cp-string (uiop:symbol-call :abcl-asdf :resolve-dependencies group artifact :version version)))

            (if cp-string
                ;; 2. Split the returned classpath string using the OS-native separator (":" or ";")
                (let* ((separator (java:jfield "java.io.File" "pathSeparator"))
                       (paths (uiop:split-string cp-string :separator separator)))

                  ;; 3. Add each resolved native jar to the classpath
                  (dolist (p paths)
                    (when (plusp (length p))
                      (uiop:symbol-call :java :add-to-classpath p))))

                (error "Failed to resolve Maven native dependency: ~A:~A" group artifact))))))))

