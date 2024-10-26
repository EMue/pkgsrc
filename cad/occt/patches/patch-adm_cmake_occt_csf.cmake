--- adm/cmake/occt_csf.cmake.orig	2022-11-11 23:19:44.000000000 +0100
+++ adm/cmake/occt_csf.cmake	2024-10-26 15:08:56.735443473 +0200
@@ -51,27 +51,19 @@
 
 # TCL
 if (USE_TCL)
-  if (WIN32)
-    set (CSF_TclLibs     "tcl86")
-  else()
     if(APPLE)
       set (CSF_TclLibs   Tcl)
     elseif(UNIX)
-      set (CSF_TclLibs   "tcl8.6")
-    endif()
+    set (CSF_TclLibs   "tcl86")
   endif()
 endif()
 
 # TK
 if (USE_TK)
-  if (WIN32)
-    set (CSF_TclTkLibs   "tk86")
-  else()
     if(APPLE)
       set (CSF_TclTkLibs Tk)
-    elseif(UNIX)
-      set (CSF_TclTkLibs "tk8.6")
-    endif()
+  else()
+    set (CSF_TclTkLibs "tk86")
   endif()
 endif()
 
@@ -142,7 +134,7 @@
       set (CSF_OpenGlLibs "GL EGL")
     endif()
     set (CSF_OpenGlesLibs "EGL GLESv2")
-    set (CSF_dl          "dl")
+    set (CSF_dl          "${CMAKE_DL_LIBS}")
     if (USE_FREETYPE)
       set (CSF_fontconfig "fontconfig")
     endif()
