--- adm/qmake/OccToolkit.pri.orig	2024-10-26 15:07:26.174525788 +0200
+++ adm/qmake/OccToolkit.pri	2024-10-26 15:07:39.353204103 +0200
@@ -19,8 +19,8 @@
 
 # CSF variables
 HAVE_FREETYPE  { CSF_FREETYPE = -lfreetype }
-CSF_TclLibs   = -ltcl8.6
-CSF_TclTkLibs = -ltk8.6
+CSF_TclLibs   = -ltcl86
+CSF_TclTkLibs = -ltk86
 HAVE_FREEIMAGE { CSF_FreeImagePlus = -lfreeimage } else:win32 { CSF_FreeImagePlus = -lwindowscodecs -lole32 }
 HAVE_FFMPEG    { CSF_FFmpeg = -lavcodec -lavformat -lswscale -lavutil }
 HAVE_TBB       { CSF_TBB = -ltbb -ltbbmalloc }
@@ -61,7 +61,7 @@
   CSF_dl = -ldl
   CSF_ThreadLibs = -lpthread -lrt
   CSF_OpenGlesLibs = -lEGL -lGLESv2
-  CSF_TclTkLibs  = -ltk8.6
+  CSF_TclTkLibs  = -ltk86
   HAVE_XLIB {
     CSF_OpenGlLibs = -lGL
     CSF_XwLibs     = -lX11
