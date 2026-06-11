# ABCL Roguelike Game Proof of Concept

* Author: Douglas P. Fields, Jr - symbolics@lisp.engineer
* License: [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
* Created: 2026-06-11
* Last updated: 2026-06-11

## Overview

This is a proof of concept small roguelike game written in Common Lisp
using the Armed Bear Common Lisp (ABCL) JVM-based Common Lisp
implementation and the libGDX game graphics library.

## Prerequisites

* ABCL
  * Mine is installed in `/opt/abcl-1.9.2`
* Java JDK 17
  * Mine is openjdk 17.0.19 2026-04-21 (Temurin-17.0.19+10)
* Maven
  * I'm using Ubuntu 24.04's provided `maven` package, `Apache Maven 3.8.7`

### Prereq test

* `JDK_HOME=/opt/jdk-17.0.19+10/ rlwrap /opt/jdk-17.0.19+10/bin/java -jar /opt/abcl-1.9.2/abcl.jar`
* `(load "load-repl.lisp")`

## How to Build and Run (Phase 1)

This project contains a GNU `Makefile` that simplifies building, running, and testing.

* **Build**: Runs ASDF compilation, which downloads and caches Maven dependencies locally:
  ```bash
  make build
  ```
* **Run**: Launches the game application. To exit the game window, press the `ESC` key:
  ```bash
  make run
  ```
* **Test**: Runs the language-native unit test suite, outputting results to standard error:
  ```bash
  make test
  ```
* **Clean**: Removes compiled FASL cache files:
  ```bash
  make clean
  ```


# Implementation Phases

A key thing to note in this phase is that as much of the
code should be in Common Lisp as possible, with minimal use
of Java except when absolutely necessary.

## Phase 1

Tooling:
* Create all the necessary files to make an ABCL project that
  uses the libGDX library using OpenJDK 17.
* Create a Makefile for GNU Make that has these targets:
  * build
  * run
  * clean
  * (A "test" target will be added in the future.)
* Create an appropriate `.asd` ASDF system definition file,
  which we will call `rlgdx.asd`.
* Create an appropriate `packages.lisp` that defines the game's
  packages.
  * Only one package will be made for now, `rlgdx`.

Game Functionality:
* All functionality should be created in `rlgdx`.
* Display a simple sprite (image) in an otherwise blank window.
* Quit when ESC is pressed.

## Phase 1A: Cleanup

* Have `make run` exit cleanly; currently it gets `Error 255`
  * Determine how to set the Java return value from ending the game to 0
* Move the tests into their own `.lisp` file
* Make the displayed sprite be half the height or width of the window -
  whichever is smaller.

## Phase 1B: CLOS

* Have the Game Class `cc.dpf.rlgdx.Game` be calling into a CLOS class that has the
  methods defined on it for `create`, `render` and `dispose` (and others - see below).
* Have that CLOS class contain all the variables which are currently global
  - except for `*app*` - as slots. Also have as a slot the dynamically created
  Class object.
* Have the CLOS class have methods for everything in libGDX's `ApplicationListener`
  interface.
* Have the Game class `cc.dpf.rlgdx.Game` extend the `com.badlogic.gdx.Game` instead
  of the current `ApplicationAdapter`.
* Define the CLOS object in a different `.lisp` file.

## Phase 1C: REPL & Libraries

Each step in this Phase should be accomplished independently, so as not to
cause complexity if one part of it doesn't work.

Tooling:
1. Create a `repl` Makefile target.
   * This should start an ACBL REPL with `rlwrap`.
   * This should load the `rlgdx` package at startup, using the
     `load-repl.lisp` file.
   * This should set the initial package to `rlgdx`.
   * This should output a message to the user telling them how
     to invoke the game.
2. Load `alexandria` library in the `.asd` and make some tests proving
   it is loaded and works.
3. Start up a backround REPL socket listener at program start.
   * Set up a way to call into the main OpenGL thread (since it is single-threaded)
     to make something run on that thread.
     See: `Gdx.app.postRunnable()`.
   * See: Swank, Slynk.
4. Create a `connect` Makefile target.
   * This should connect to a running instance of the game via Swank (or the like)
     and give a nice REPL to the end user.

## Phase 2A: Packaging for Linux

TODO: Package this as a file/directory that can be run on anyone's
Linux computer that has JRE 17.

## Phase 2B: Packaging for Windows

TODO

## Phase 2C: Packaging for Android

TODO

## Phase 3: TBD

## Phase N:

* Packaging for macOS, iOS - I don't have any current Macs so can't do this.


# Assets

Located in the `assets` subdirectory.

* `sprite.png`: Gemini created sprite for testing


# License

Copyright 2026 Douglas P. Fields, Jr.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

* http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
