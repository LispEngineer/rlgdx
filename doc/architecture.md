# Architecture

* Author: Douglas P. Fields, Jr. - symbolics@lisp.engineer
* License: [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
* Created: 2026-06-11
* Last updated: 2026-06-11

This describes the software architecture for the game.

## Overview

The game is split into two main architectural parts.

First, the game itself, including all the state, all the actions,
and what is going on in the game world, is entirely written in pure
Common Lisp. This should preferably use nothing that is not
transferable between Common Lisp implementations such as
ABCL, SBCL, ECL, etc. If necessary, potentially non-portable elements
should be handled through compatibility libraries
(e.g., Closer MOP, UIOP, etc.).

Second, the UI interface is necessarily very specific to the
chosen platform. This implementation is written for ABCL using
libGDX; other valid choices could be DotCL with MonoGame or Godot,
ECL with Unreal, etc. It should even be possible to write the
UI in one language and connect to a "game server" layer on top
of the game state engine in the first part. This layer will necessarily
be less portable or even non-portable.

However, despite this, the desired intent of this implementation is
to create as much of the UI layer in Common Lisp as possible, and
abstract the platform/library specific things behind Lispy
interfaces, simply for developer ergonomics. Given how much coding
seems to be done by ML/AI tooling in recent months, the focus on
the ergonomics of Common Lisp feels a bit passé, but there it is.

