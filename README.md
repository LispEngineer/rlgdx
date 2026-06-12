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
* Quicklisp
  * This must be installed in `~/quicklisp/setup.lisp`

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

## Phase 1 - DONE

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

## Phase 1A: Cleanup - DONE

* Have `make run` exit cleanly; currently it gets `Error 255`
  * Determine how to set the Java return value from ending the game to 0
* Move the tests into their own `.lisp` file
* Make the displayed sprite be half the height or width of the window -
  whichever is smaller.

## Phase 1B: CLOS - DONE

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

## Phase 2D: Package for HTML5

TODO

## Phase 3: TBD

## Phase N:

* Packaging for macOS, iOS - I don't have any current Macs so can't do this.


# Dependency Management

The project uses a hybrid vendoring approach to manage third-party Common Lisp libraries.
It uses Quicklisp's built-in `bundle-systems` feature to fetch and package dependencies 
into a self-contained `vendor/` directory.

This ensures that the repository remains fully self-contained, and anyone can build or run
the game offline without needing Quicklisp installed locally, while still enabling the
easy update of libraries using Quicklisp's powerful package resolution.

## How it works
1. **Fetching**: The script `update-dependencies.lisp` loads the local Quicklisp installation 
   and uses `ql:bundle-systems` to download the required libraries (like `alexandria`) directly
   into the `vendor/` directory.
   * This is typically installed in `~/quicklisp/setup.lisp` after it's been set up.
2. **Loading**: The script automatically generates a `vendor/bundle.lisp` file.
3. **Execution**: During `make build`, `make run`, `make test`, or when running the `load-repl.lisp`
   script, the system checks if `vendor/bundle.lisp` exists. If it does, it loads it. This configures
   ASDF to seamlessly load the vendored libraries before loading the main project system.

## How to use it

### Updating existing dependencies

To re-download or update the existing dependencies from Quicklisp, run:
```bash
make vendor-deps
```
*Note: You must have Quicklisp installed at `~/quicklisp/setup.lisp` to run this target.*

### Adding new dependencies

To add a new library:
1. Open `update-dependencies.lisp`.
2. Locate the line: `(ql:bundle-systems '(:alexandria) :to "vendor/")`
3. Add the new library to the quoted list, for example: 
   * `(ql:bundle-systems '(:alexandria :bordeaux-threads) :to "vendor/")`
4. Add the library to the `:depends-on` list in `rlgdx.asd`.
5. Run `make vendor-deps`.

## References

* [Quicklisp Site](https://www.quicklisp.org/beta/)
* [Quicklisp Bundles Documentation](https://www.quicklisp.org/beta/bundles.html) - Documentation 
  on how `ql:bundle-systems` creates standalone bundles that can be loaded independently.


# Assets

Located in the `assets` subdirectory.

* `sprite.png`: Gemini created sprite for testing


# Java and CLOS Class Interface into libGDX

The game initializes a hybrid class interface bridging the Java Virtual Machine (JVM)
and the Common Lisp Object System (CLOS). This design delegates libGDX application
lifecycle events directly to CLOS methods.

## Architecture

1. **Java Runtime Class Generation**:
   The runtime Java class `cc.dpf.rlgdx.Game` is defined dynamically at startup using
   `java:jnew-runtime-class`. It extends the standard `com.badlogic.gdx.Game` class.
2. **Encapsulated Field Reference**:
   The Java class contains a public field referencing the CLOS class instance. During
   instantiation, the CLOS instance is passed to the constructor and stored in this field.
3. **Delegation**:
   When libGDX invokes lifecycle events (like `create`, `render`, etc.) on the Java game
   instance, they trigger inline Lisp lambda closures. These closures retrieve the CLOS
   object from the Java field and delegate execution to corresponding CLOS generic functions.

## Java Class: `cc.dpf.rlgdx.Game`

This is dynamically created with `java:jnew-runtime-class`. Since it won't be available
to the regular system class loader, to create instances it is necessary to use the class
object, which is stored in `*game-class*`.

### Fields
* `CLOSGame`: A public instance field of type `org.armedbear.lisp.LispObject`. Stores the
  reference to the corresponding Lisp `rlgdx-game` CLOS object.

### Constructors
* `cc.dpf.rlgdx.Game(LispObject closGame)`: Initializes the object by storing the reference
  to the CLOS object in the `CLOSGame` field.

### Methods
* `void create()`: Retrieves `CLOSGame` and calls `gdx-create`.
* `void resize(int width, int height)`: Retrieves `CLOSGame` and calls `gdx-resize`.
* `void render()`: Retrieves `CLOSGame` and calls `gdx-render`.
* `void pause()`: Retrieves `CLOSGame` and calls `gdx-pause`.
* `void resume()`: Retrieves `CLOSGame` and calls `gdx-resume`.
* `void dispose()`: Retrieves `CLOSGame` and calls `gdx-dispose`.

Each method passes the `this` object as the first parameter. This is redundant as
the `rlgdx-game` also stores a reference to the `cc.dpf.rlgdx.Game` object.

## CLOS Class: `rlgdx-game`

### Slots
* `batch`: Accessor `game-batch` (initform `nil`). Stores the
  `com.badlogic.gdx.graphics.g2d.SpriteBatch` used for rendering.
* `texture`: Accessor `game-texture` (initform `nil`). Stores the loaded
  `com.badlogic.gdx.graphics.Texture` asset representing the sprite.
* `game-class`: Accessor `game-class` (initform `nil`). Stores the generated Java class reference.
* `game-instance`: Accessor `game-instance` (initform `nil`). Stores the instance of the Java class.
* `exit-on-close`: Accessor `game-exit-on-close` (initform `*exit-on-close*`).
  Determines if the JVM exits upon window disposal.

### Methods
* `gdx-create (game this)`: Initializes graphics, creating the sprite batch and loading the texture.
* `gdx-resize (game this width height)`: Placeholder method for handling window resizing.
* `gdx-render (game this)`: Checks for the `ESC` key to exit, clears the screen,
  and draws the centered, dynamically scaled sprite.
* `gdx-pause (game this)`: Placeholder method for handling application minimization or pausing.
* `gdx-resume (game this)`: Placeholder method for handling application focus restoration.
* `gdx-dispose (game this)`: Releases the sprite batch and texture assets to prevent JVM memory leaks.

The first parameter is, as always, the CLOS instance. The second is the Java class
instance by convention.


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
