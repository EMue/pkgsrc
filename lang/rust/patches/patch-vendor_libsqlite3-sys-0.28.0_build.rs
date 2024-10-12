--- vendor/libsqlite3-sys-0.28.0/build.rs.orig	2024-10-12 19:21:20.374450457 +0200
+++ vendor/libsqlite3-sys-0.28.0/build.rs	2024-10-12 19:21:34.912988990 +0200
@@ -208,6 +208,8 @@
             }
         }
 
+        println!("cargo:rustc-link-lib=dylib=gcc_s");
+
         // on android sqlite can't figure out where to put the temp files.
         // the bundled sqlite on android also uses `SQLITE_TEMP_STORE=3`.
         // https://android.googlesource.com/platform/external/sqlite/+/2c8c9ae3b7e6f340a19a0001c2a889a211c9d8b2/dist/Android.mk
