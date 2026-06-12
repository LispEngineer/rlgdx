;;; tests.lisp
;;;
;;; Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
;;; Copyright 2026 Douglas P. Fields, Jr. - License Apache 2.0
;;;
;;; Language-native unit tests for the rlgdx project.

(in-package #:rlgdx)

(defun run-tests ()
  "Runs language-native tests for the rlgdx project and prints the results to *error-output*."
  (format *error-output* "~&[TEST] Running rlgdx unit tests...~%")
  (let ((failures 0))
    ;; Test 1: Check if sprite image file exists
    (if (probe-file "assets/sprite.png")
      (format *error-output* "[TEST] PASS: assets/sprite.png exists.~%")
      (progn
        (format *error-output* "[TEST] FAIL: assets/sprite.png does not exist.~%")
        (incf failures)))

    ;; Test 2: Check package exports
    (if (and (find-symbol "MAIN" :rlgdx)
             (find-symbol "RLGDX-GAME" :rlgdx)
             (find-symbol "GAME-BATCH" :rlgdx)
             (find-symbol "GAME-TEXTURE" :rlgdx)
             (find-symbol "GAME-INSTANCE" :rlgdx))
      (format *error-output* "[TEST] PASS: Exported package symbols are present.~%")
      (progn
        (format *error-output* "[TEST] FAIL: Missing exported symbols in package :rlgdx.~%")
        (incf failures)))

    ;; Test 3: Check class definition
    (handler-case
      (progn
        (ensure-game-class)
        (if *game-class*
          (format *error-output* "[TEST] PASS: Game class successfully defined in JVM.~%")
          (progn
            (format *error-output* "[TEST] FAIL: Game class is nil.~%")
            (incf failures))))
      (error (e)
        (format *error-output* "[TEST] FAIL: Error creating Game class: ~A~%" e)
        (incf failures)))

    ;; Test 4: Check Alexandria Integration
    (handler-case
      (let ((iota-list (alexandria:iota 5))
            (expected-list '(0 1 2 3 4)))
        (alexandria:if-let ((matched (equal iota-list expected-list)))
          (format *error-output* "[TEST] PASS: Alexandria successfully loaded and working.~%")
          (progn
            (format *error-output* "[TEST] FAIL: Alexandria iota returned ~A instead of expected ~A.~%" iota-list expected-list)
            (incf failures))))
      (error (e)
        (format *error-output* "[TEST] FAIL: Error running Alexandria tests: ~A~%" e)
        (incf failures)))

    ;; Summary
    (if (zerop failures)
      (progn
        (format *error-output* "[TEST] SUMMARY: All tests passed successfully.~%")
        t)
      (progn
        (format *error-output* "[TEST] SUMMARY: ~D test(s) failed.~%" failures)
        nil))))
