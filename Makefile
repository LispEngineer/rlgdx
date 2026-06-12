# Makefile for the ABCL Roguelike Game Proof of Concept (rlgdx)
# Targets Armed Bear Common Lisp (ABCL) on OpenJDK 17.

JDK_PATH = /opt/jdk-17.0.19+10
ABCL_JAR = /opt/abcl-1.9.2/abcl.jar
MAVEN_LIB = /usr/share/maven/lib/
RLWRAP = /usr/bin/rlwrap

# Standard execution command for launching ABCL
ABCL_CMD = JDK_HOME=$(JDK_PATH) $(JDK_PATH)/bin/java -jar $(ABCL_JAR)
REPL_CMD = JDK_HOME=$(JDK_PATH) $(RLWRAP) $(JDK_PATH)/bin/java -jar $(ABCL_JAR)

.PHONY: all build run test clean repl vendor-deps

all: build

# Compiles the rlgdx ASDF system
build:
	$(ABCL_CMD) \
		--eval '(require :abcl-contrib)' \
		--eval '(require :abcl-asdf)' \
		--eval '(setf abcl-asdf:*mvn-libs-directory* #p"$(MAVEN_LIB)")' \
		--eval '(abcl-asdf:ensure-mvn-version)' \
		--eval '(push #p"$(CURDIR)/" asdf:*central-registry*)' \
		--eval '(when (probe-file "vendor/bundle.lisp") (load "vendor/bundle.lisp"))' \
		--eval '(asdf:compile-system :rlgdx)' \
		--eval '(ext:quit)'

# Loads the system and starts the game loop
run:
	$(ABCL_CMD) \
		--eval '(require :abcl-contrib)' \
		--eval '(require :abcl-asdf)' \
		--eval '(setf abcl-asdf:*mvn-libs-directory* #p"$(MAVEN_LIB)")' \
		--eval '(abcl-asdf:ensure-mvn-version)' \
		--eval '(push #p"$(CURDIR)/" asdf:*central-registry*)' \
		--eval '(when (probe-file "vendor/bundle.lisp") (load "vendor/bundle.lisp"))' \
		--eval '(asdf:load-system :rlgdx)' \
		--eval '(rlgdx:main)'

# Runs the native unit tests
test:
	$(ABCL_CMD) \
		--eval '(require :abcl-contrib)' \
		--eval '(require :abcl-asdf)' \
		--eval '(setf abcl-asdf:*mvn-libs-directory* #p"$(MAVEN_LIB)")' \
		--eval '(abcl-asdf:ensure-mvn-version)' \
		--eval '(push #p"$(CURDIR)/" asdf:*central-registry*)' \
		--eval '(when (probe-file "vendor/bundle.lisp") (load "vendor/bundle.lisp"))' \
		--eval '(asdf:load-system :rlgdx)' \
		--eval '(rlgdx:main)' \
		-- --test

repl:
	$(REPL_CMD) \
	  --eval '(load "load-repl.lisp")' \
	  --eval '(in-package :rlgdx)'

# Removes compiled Lisp FASL files from the common-lisp ASDF cache
clean:
	rm -rf ~/.cache/common-lisp/abcl-*/home/dfields/src/cl/abcl-libgdx/

# Updates project dependencies from Quicklisp
vendor-deps:
	$(ABCL_CMD) --eval '(load "update-dependencies.lisp")'
