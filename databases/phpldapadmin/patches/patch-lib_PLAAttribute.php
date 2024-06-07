$NetBSD: patch-lib_PLAAttribute.php,v 1.1.16.1 2024/06/07 13:52:43 bsiegert Exp $

Avoid deprecation warnings.

--- lib/PLAAttribute.php.orig	2024-01-10 22:23:54.000000000 +0000
+++ lib/PLAAttribute.php
@@ -78,6 +78,9 @@ class PLAAttribute {
 	protected $autovalue = array();
 	protected $postvalue = array();
 
+	# Additional properties
+	public $js;
+
 	public function __construct($name,$values,$server_id,$source=null) {
 		if (DEBUG_ENABLED && (($fargs=func_get_args())||$fargs='NOARGS'))
 			debug_log('Entered (%%)',5,0,__FILE__,__LINE__,__METHOD__,$fargs);
