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

## Phase 2

Tooling:
* Create a `repl` Makefile target
  * This should start an ACBL REPL with `rlwrap`
  * This should load the `rlgdx` package at startup.
  * This should set the initial package to `rlgdx`.
  * This should output a message to the user telling them how
    to run the game.




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
