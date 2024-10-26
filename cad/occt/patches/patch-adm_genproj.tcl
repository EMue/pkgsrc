--- adm/genproj.tcl.orig	2024-10-26 15:06:52.377915235 +0200
+++ adm/genproj.tcl	2024-10-26 15:07:17.375408247 +0200
@@ -1403,9 +1403,9 @@
   if { "$::HAVE_FREETYPE" == "true" } {
     set aLibsMap(CSF_FREETYPE) "freetype"
   }
-  set aLibsMap(CSF_TclLibs)   "tcl8.6"
+  set aLibsMap(CSF_TclLibs)   "tcl86"
   if { "$::HAVE_TK" == "true" } {
-    set aLibsMap(CSF_TclTkLibs) "tk8.6"
+    set aLibsMap(CSF_TclTkLibs) "tk86"
   }
   if { "$::HAVE_FREEIMAGE" == "true" } {
     if { "$theOS" == "wnt" } {
@@ -1518,7 +1518,7 @@
       } else {
         set aLibsMap(CSF_ThreadLibs) "pthread rt"
         if { "$::HAVE_TK" == "true" } {
-          set aLibsMap(CSF_TclTkLibs) "tk8.6"
+          set aLibsMap(CSF_TclTkLibs) "tk86"
         }
         if { "$::HAVE_XLIB" == "true" } {
           set aLibsMap(CSF_XwLibs)     "X11"
