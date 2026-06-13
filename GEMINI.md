# Gemini and Antigravity Instructions

# General Instructions

* You will **never** use git to stage or commit any changes.
  You must **only** use git for read-only commands.
* Do include detailed comments with any code written,
  or changes to code made.
  * This includes: You must add detailed documentaion strings
    or comments in the language appropriate fashion.
* Update the `README.md` (sibling to this file)
  file with documentation on new features.
* Update `antigravity-log.md` (as a sibling file to this
  file) with any explanation you provide me,
  and a log of any changes you make to any files.
  * Create this file if it does not exist
* Do NOT make any changes to any other directories' files except
  for this project's directory and sub-directories unless explicitly
  directed by the user. All the work for this project is to be done
  on this directory's code only.
* Any question about *how* to do something should be answered with
  an explanation on how to accomplish the thing requested, without
  you making any changes to any files or executing any commands that
  could change files.
* When writing comments or documentation, do *not* use personal
  pronouns such as "we" or "I." 
  * For example, instead of saying
    "We still capture this metadata for our Lisp packaging..."
    say instead "This metadata is still captured for the Lisp packaging..."


# Locations

* The JDK to use is located in `/opt/jdk-17.0.19+10/`.
* ABCL source code, if necessary, is located in `../abcl/`
* ABCL manual, if necessary, is at `../abcl-1.9.2.pdf`


# Useful Commands

* Start an ABCL REPL: `JDK_HOME=/opt/jdk-17.0.19+10/ /opt/jdk-17.0.19+10/bin/java -jar /opt/abcl-1.9.2/abcl.jar`


# Code Style Instructions

## Testing

All new code must have tests. However:
* There is no test framework in use, so use language-native capabilities.
* Print the results of tests on error output.
* Tests should either run:
  * With a command line flag like `--test`
  * Every time the program starts

## Common Lisp Code Style

* Do not use the short-circuit binary operators `and` and `or` as
  flow control mechanisms. In other words, do *not* write code
  like this:
  ```lisp
  (and arg-type
       spec-type
    (do-something arg-type arg-type))
  ```
  But rather, write code like this:
  ```lisp
  (when (and arg-type spec-type)
    (do-something spec-type arg-type))
  ```
* Format the "then" and "else" clauses of a Common Lisp `if` statement
  aligned with one indent only.

# Markdown

* Don't put gratuitous spaces in markdown files; use the minimal 
  synctactally correct whitespace
  * Example: Never have two spaces where one is semantically all
    that is necessary
* Wrap markdown lines between 80 and 100 characters long except when
  not syntactically possible.
* If you are backtick-quoting something that contains a (single) backtick,
  you must use two leading and trailing backticks. Then, the single
  backtick can be left alone (that is, unduplicated).
  * Example: ``List`1``
  * If the backtick is the first item that is in the backtick-quoted
    expression, just add a preceeding space for now.


# Language

This software targets the [ABCL](https://abcl.org/)
Common Lisp environment on top of the
OpenJDK 17 Java Virtual Machine.
It also uses the
[libGDX](https://libgdx.com/) library for the user interface.

This code is written primarily in Common Lisp. Additional utilities
may be written in Java to ease the interface between the
ABCL code and the libGDX or Java code.

It is running on Ubuntu 24.04 on the x86_64 platform. When possible,
try to keep the code cross-platform, at least so it can be built and
run on Windows 11 as well.

This project is publicly available on [GitHub](TODO).

Some useful Common Lisp documentation:
* [Common Lisp HyperSpec](https://www.lispworks.com/documentation/HyperSpec/Front/index.htm)
* [Common Lisp Nova Spec](https://novaspec.org/cl/)
* [Practical Common Lisp](https://gigamonkeys.com/book/)
* [Common Lisp Cookbook](https://lispcookbook.github.io/cl-cookbook/)
* [Common Lisp Recipes]() is not available in HTML format online.
* [Common Lisp: The Language](https://www.cs.cmu.edu/Groups/AI/html/cltl/cltl2.html)
* [Lisp Games](https://github.com/lispgames/lispgames.github.io/wiki/Lisp-Games)
  * [Common Lisp Game Notes](https://github.com/lispgames/lispgames.github.io/wiki/Common-Lisp)
  * [Free Game Assets](https://github.com/lispgames/lispgames.github.io/wiki/Assets)

ABCL (Armed Bear Common Lisp) information:
* [ABCL Home Page](https://abcl.org/)
* [ABCL 1.9.2 Manual PDF](https://abcl.org/releases/1.9.2/abcl-1.9.2.pdf)
* [ABCL GitHub](https://github.com/armedbear/abcl)

# Libraries

The Common Lisp libraries in use are:
* Package management: [ASDF GitHub](https://github.com/fare/asdf)
  * [ASDF Site](https://asdf.common-lisp.dev/)
  * [ASDF Manual - HTML](https://asdf.common-lisp.dev/asdf.html)
  * [ASDF Manual - PDF](https://asdf.common-lisp.dev/asdf.pdf)
  * [ASDF Best Practices](https://gitlab.common-lisp.net/asdf/asdf/blob/master/doc/best_practices.md)
  * [UIOP Readme](https://gitlab.common-lisp.net/asdf/asdf/blob/master/uiop/README.md)
  * [UIOP Manual - HTML](https://asdf.common-lisp.dev/uiop.html)
  * [UIOP Manual - PDF](https://asdf.common-lisp.dev/uiop.pdf)
* Alexandria
  * [Alexandria - GitHub](https://github.com/salva/cl-alexandria)
  * [Alexandria - Reference Manual](https://quickref.common-lisp.net/alexandria.html)
  * [Alexandria - ReadTheDocs](https://common-lisp-libraries.readthedocs.io/alexandria/)
* Slynk (Network REPL)
  * [Sly - GitHub](https://github.com/joaotavora/sly)
  * [Sly - Documentation](https://joaotavora.github.io/sly/)

The Java libraries in use are:
* [libGDX Home](https://libgdx.com/)
* [libGDX GitHub](https://github.com/libgdx/libgdx)
* [libGDX Maven Integration](https://libgdx.com/wiki/articles/maven-integration)
* [libGDX Clojure Example](https://libgdx.com/wiki/jvm-langs/using-libgdx-with-clojure)

## Other Libraries of Interest but Not (Yet) in Use

* [QuickLisp](www.quicklisp.org/beta/) - Package downloader for CL
  * [QuickLisp Libraries](https://www.quicklisp.org/beta/releases.html)
  * This is not yet working/available on DotCL
  * [Qlot](https://github.com/fukamachi/qlot) - project-local library 
    installer using Quicklisp
    * [Qlot HN Discussion](https://news.ycombinator.com/item?id=41167921)
  * [Ultralisp](https://ultralisp.org/) - Frequently updated package repository
    for QuickLisp

* Common CL libraries:
  * Seraphim
  * Anaphora
  * Slynk