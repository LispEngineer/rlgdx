#|
(defsystem #:rlgdx
  :description "Roguelike Game Proof of Concept in ABCL with libGDX"
  :version "0.0.1"
  :defsystem-depends-on (#:abcl-asdf)  
  :components (
               (:mvn "com.badlogicgames.gdx/gdx" :version "1.14.2")
               (:mvn "com.badlogicgames.gdx/gdx-backend-lwjgl" :version "1.14.2")
               (:mvn "com.badlogicgames.gdx/gdx-box2d" :version "1.14.2")
               (:mvn "com.badlogicgames.gdx/gdx-box2d-platform" :version "1.14.2") ;; :classifier "natives-desktop"
               (:mvn "com.badlogicgames.gdx/gdx-bullet" :version "1.14.2")
               (:mvn "com.badlogicgames.gdx/gdx-bullet-platform" :version "1.14.2") ;; :classifier "natives-desktop"
               (:mvn "com.badlogicgames.gdx/gdx-platform" :version "1.14.2") ;; :classifier "natives-desktop"
              ))
|#

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
    (:file "main" :depends-on ("packages"))
    (:file "tests" :depends-on ("main"))
  )

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

#|
:perform 
  (asdf:load-op :after (op c)
    (let ((natives '(;; Format: (groupId artifactId)
                     ("com.badlogicgames.gdx" "gdx-box2d-platform")
                     ("com.badlogicgames.gdx" "gdx-bullet-platform")
                     ("com.badlogicgames.gdx" "gdx-platform"))))
      
      (dolist (coord natives)
        (let ((group (first coord))
              (artifact (second coord)))
          
          (format t "~&Locating native binaries for: ~A:~A~%" group artifact)
          
          ;; 1. Use the official API function
          (let ((cp-string (uiop:symbol-call :abcl-asdf :resolve-dependencies 
                                             group artifact 
                                             :version "1.14.2" 
                                             :classifier "natives-desktop")))
            (if cp-string
              ;; 2. Split the returned classpath string using the OS-native separator
              (let* ((separator (java:jfield "java.io.File" "pathSeparator"))
                      (paths (uiop:split-string cp-string :separator separator)))

                ;; 3. Add each resolved native jar to the classpath
                (dolist (p paths)
                  (when (plusp (length p))
                    (uiop:symbol-call :java :add-to-classpath p))))

              (error "Failed to resolve Maven native dependency: ~A:~A" group artifact))))))))

|#

#|
  :perform 
    (asdf:load-op :after (op c)
      (let ((natives '(;; Format: "groupId:artifactId:packaging:classifier:version"
                      "com.badlogicgames.gdx:gdx-box2d-platform:jar:natives-desktop:1.14.2"
                      "com.badlogicgames.gdx:gdx-bullet-platform:jar:natives-desktop:1.14.2"
                      "com.badlogicgames.gdx:gdx-platform:jar:natives-desktop:1.14.2")))
        (dolist (coordinate natives)
          (format t "~&Locating and loading native binaries: ~A~%" coordinate)
          ;; Resolve the Maven string directly to a local path/string
          (let ((jar-path (uiop:symbol-call :abcl-asdf :resolve coordinate)))
            (if jar-path
              ;; Add it directly to the JVM classpath
              (uiop:symbol-call :java :add-to-classpath jar-path)
              (error "Failed to resolve Maven coordinate: ~A" coordinate)))))))
|#

#|
  :perform 
  (asdf:load-op :after (op c)
    (let ((natives '(;; Format: "groupId:artifactId:packaging:classifier:version"
                     "com.badlogicgames.gdx:gdx-box2d-platform:jar:natives-desktop:1.14.2"
                     "com.badlogicgames.gdx:gdx-bullet-platform:jar:natives-desktop:1.14.2"
                     "com.badlogicgames.gdx:gdx-platform:jar:natives-desktop:1.14.2")))
      (dolist (coordinate natives)
        (format t "~&Locating and loading native binaries: ~A~%" coordinate)
        ;; 1. Resolve the string coordinate directly 
        (let* ((resolved-obj (uiop:symbol-call :abcl-asdf :resolve coordinate))
               ;; 2. Convert the resolved component to an absolute filepath string
               (jar-path-raw (uiop:symbol-call :abcl-asdf :as-classpath resolved-obj))
               (jar-path (uiop:ensure-string jar-path-raw)))
          (if (and jar-path (not (string= jar-path "")))
              ;; 3. Add the string path directly to the java classpath
              (uiop:symbol-call :java :add-to-classpath jar-path)
              (error "Failed to resolve Maven coordinate: ~A" coordinate)))))))
|#

#|
  :perform 
    (asdf:load-op :after (op c)
      ;; Iterate and force-load the native desktop classifiers via Aether/Maven
      (dolist (coordinate '("com.badlogicgames.gdx:gdx-box2d-platform:jar:natives-desktop:1.14.2"
                            "com.badlogicgames.gdx:gdx-bullet-platform:jar:natives-desktop:1.14.2"
                            "com.badlogicgames.gdx:gdx-platform:jar:natives-desktop:1.14.2"))
        (format t "~&Loading native binaries: ~A~%" coordinate)
        (uiop:symbol-call :java :add-to-classpath 
          (uiop:symbol-call :abcl-asdf :resolve coordinate)))))
|#

#|
  :perform 
  (asdf:load-op :after (op c)
    (let ((natives '(;; Format: "groupId:artifactId:packaging:classifier:version"
                     "com.badlogicgames.gdx:gdx-box2d-platform:jar:natives-desktop:1.14.2"
                     "com.badlogicgames.gdx:gdx-bullet-platform:jar:natives-desktop:1.14.2"
                     "com.badlogicgames.gdx:gdx-platform:jar:natives-desktop:1.14.2")))
      (dolist (coordinate natives)
        (format t "~&Locating and loading native binaries: ~A~%" coordinate)
        ;; 1. Resolve the string coordinate directly 
        (let* ((resolved-obj (uiop:symbol-call :abcl-asdf :resolve coordinate))
               ;; 2. Convert the resolved component to an absolute filepath string
               (jar-path-raw (uiop:symbol-call :abcl-asdf :as-classpath resolved-obj))
               (jar-path (uiop:ensure-string jar-path-raw)))
          (if (and jar-path (not (string= jar-path "")))
              ;; 3. Add the string path directly to the java classpath
              (uiop:symbol-call :java :add-to-classpath jar-path)
              (error "Failed to resolve Maven coordinate: ~A" coordinate)))))))
|#

#|
  :perform 
  (asdf:load-op :after (op c)
    (let ((natives '(;; Format: "groupId:artifactId:packaging:classifier:version"
                     "com.badlogicgames.gdx:gdx-box2d-platform:jar:natives-desktop:1.14.2"
                     "com.badlogicgames.gdx:gdx-bullet-platform:jar:natives-desktop:1.14.2"
                     "com.badlogicgames.gdx:gdx-platform:jar:natives-desktop:1.14.2")))
      (dolist (coordinate natives)
        (format t "~&Locating and loading native binaries: ~A~%" coordinate)
        ;; 1. Use the internal maker to build the MVN object descriptor cleanly
        (let ((mvn-obj (uiop:symbol-call :abcl-asdf '#:make-mvn coordinate)))
          ;; 2. Resolve the object and turn it into a valid system path
          (let ((jar-path (uiop:symbol-call :abcl-asdf :as-classpath 
                                            (uiop:symbol-call :abcl-asdf :resolve mvn-obj))))
            (if jar-path
              (uiop:symbol-call :java :add-to-classpath jar-path)
              (error "Failed to resolve Maven coordinate: ~A" coordinate))))))))
|#

#|
  :perform 
    (asdf:load-op :after (op c)
      (let ((natives '(;; (group-id artifact-id version)
                      ("com.badlogicgames.gdx" "gdx-box2d-platform" "1.14.2")
                      ("com.badlogicgames.gdx" "gdx-bullet-platform" "1.14.2")
                      ("com.badlogicgames.gdx" "gdx-platform" "1.14.2"))))
        (dolist (dep natives)
          (let* ((group (first dep))
                 (artifact (second dep))
                 (version (third dep))
                 ;; Tell Maven to look explicitly for the "natives-desktop" classifier
                 (classifier-string (format nil "~A:~A:jar:natives-desktop:~A" group artifact version)))
            (format t "~&Locating and loading native binaries: ~A~%" classifier-string)
            (let ((jar-path (uiop:symbol-call :abcl-asdf :resolve-dependencies group artifact :version version :classifier "natives-desktop")))
              (if jar-path
                (uiop:symbol-call :java :add-to-classpath jar-path)
                (error "Failed to resolve Maven coordinate: ~A" classifier-string))))))
    ))
|#

#|
  :perform 
    (asdf:load-op :after (op c)
      (let ((natives '(;; GroupId : ArtifactId : Packaging : Classifier : Version
                      "com.badlogicgames.gdx:gdx-box2d-platform:jar:natives-desktop:1.14.2"
                      "com.badlogicgames.gdx:gdx-bullet-platform:jar:natives-desktop:1.14.2"
                      "com.badlogicgames.gdx:gdx-platform:jar:natives-desktop:1.14.2")))
        (dolist (coordinate natives)
          (format t "~&Locating and loading native binaries: ~A~%" coordinate)
          (let ((jar-path (uiop:symbol-call :abcl-asdf :locate-mvn coordinate)))
            (if jar-path
              (uiop:symbol-call :java :add-to-classpath jar-path)
              (error "Failed to resolve Maven coordinate: ~A" coordinate)))))))

  :perform 
  (asdf:load-op :after (op c)
    (let ((natives '(;; (group-id artifact-id version)
                     ("com.badlogicgames.gdx" "gdx-box2d-platform" "1.14.2")
                     ("com.badlogicgames.gdx" "gdx-bullet-platform" "1.14.2")
                     ("com.badlogicgames.gdx" "gdx-platform" "1.14.2"))))
      (dolist (dep natives)
        (let* ((group (first dep))
               (artifact (second dep))
               (version (third dep))
               ;; Tell Maven to look explicitly for the "natives-desktop" classifier
               (classifier-string (format nil "~A:~A:jar:natives-desktop:~A" group artifact version)))
          (format t "~&Locating and loading native binaries: ~A~%" classifier-string)
          (let ((jar-path (uiop:symbol-call :abcl-asdf :resolve-dependencies group artifact :version version :classifier "natives-desktop")))
            (if jar-path
                (uiop:symbol-call :java :add-to-classpath jar-path)
                (error "Failed to resolve Maven coordinate: ~A" classifier-string)))))))
|#

#|
  :perform 
    (asdf:load-op :after (op c)
      ;; Force-load the native desktop classifier via Aether/Maven
      (let ((native-coordinate "com.badlogicgames.gdx:gdx-box2d-platform:jar:natives-desktop:1.14.2"))
        (format t "~&Loading native binaries: ~A~%" native-coordinate)
        (uiop:symbol-call :java :add-to-classpath 
          (uiop:symbol-call :abcl-asdf :as-classpath 
            (uiop:symbol-call :abcl-asdf :resolve native-coordinate))))
      (let ((native-coordinate "com.badlogicgames.gdx:gdx-bullet-platform:jar:natives-desktop:1.14.2"))
        (format t "~&Loading native binaries: ~A~%" native-coordinate)
        (uiop:symbol-call :java :add-to-classpath 
          (uiop:symbol-call :abcl-asdf :as-classpath 
            (uiop:symbol-call :abcl-asdf :resolve native-coordinate))))
      (let ((native-coordinate "com.badlogicgames.gdx:gdx-platform:jar:natives-desktop:1.14.2"))
        (format t "~&Loading native binaries: ~A~%" native-coordinate)
        (uiop:symbol-call :java :add-to-classpath 
          (uiop:symbol-call :abcl-asdf :as-classpath 
            (uiop:symbol-call :abcl-asdf :resolve native-coordinate))))
|#