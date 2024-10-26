--- src/tools/hunspell.cxx.orig	2024-10-26 18:55:46.194118321 +0200
+++ src/tools/hunspell.cxx	2024-10-26 18:56:02.812462204 +0200
@@ -168,12 +168,8 @@
 #endif
 
 #ifdef HAVE_CURSES_H
-#ifdef HAVE_NCURSESW_CURSES_H
-#include <ncursesw/curses.h>
-#else
 #include <curses.h>
 #endif
-#endif
 
 #ifdef HAVE_READLINE
 #include <readline/readline.h>
