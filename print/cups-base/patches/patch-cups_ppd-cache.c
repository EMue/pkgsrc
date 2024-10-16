$NetBSD: patch-cups_ppd-cache.c,v 1.1 2024/09/27 07:07:46 wiz Exp $

Security fixes:
    2abe1ba8a Fix warnings for unused vars.
    1e6ca5913 Quote PPD localized strings.
    e0630cd18 PPDize preset and template names.
    04bb2af45 Refactor make-and-model code.
    9939a70b7 Mirror IPP Everywhere printer changes from master.

--- cups/ppd-cache.c.orig	2024-06-18 11:11:05.000000000 +0000
+++ cups/ppd-cache.c
@@ -32,6 +32,7 @@
 static int	cups_connect(http_t **http, const char *url, char *resource, size_t ressize);
 static int	cups_get_url(http_t **http, const char *url, char *name, size_t namesize);
 static const char *ppd_inputslot_for_keyword(_ppd_cache_t *pc, const char *keyword);
+static void	ppd_put_string(cups_file_t *fp, cups_lang_t *lang, cups_array_t *strings, const char *ppd_option, const char *ppd_choice, const char *pwg_msgid);
 static void	pwg_add_finishing(cups_array_t *finishings, ipp_finishings_t template, const char *name, const char *value);
 static void	pwg_add_message(cups_array_t *a, const char *msg, const char *str);
 static int	pwg_compare_finishings(_pwg_finishings_t *a, _pwg_finishings_t *b);
@@ -3197,9 +3198,10 @@ _ppdCreateFromIPP2(
   ipp_t			*media_col,	/* Media collection */
 			*media_size;	/* Media size collection */
   char			make[256],	/* Make and model */
-			*model,		/* Model name */
+			*mptr,		/* Pointer into make and model */
 			ppdname[PPD_MAX_NAME];
 		    			/* PPD keyword */
+  const char		*model;		/* Model name */
   int			i, j,		/* Looping vars */
 			count,		/* Number of values */
 			bottom,		/* Largest bottom margin */
@@ -3221,8 +3223,7 @@ _ppdCreateFromIPP2(
   int			have_qdraft = 0,/* Have draft quality? */
 			have_qhigh = 0;	/* Have high quality? */
   char			msgid[256];	/* Message identifier (attr.value) */
-  const char		*keyword,	/* Keyword value */
-			*msgstr;	/* Localized string */
+  const char		*keyword;	/* Keyword value */
   cups_array_t		*strings = NULL;/* Printer strings file */
   struct lconv		*loc = localeconv();
 					/* Locale data */
@@ -3260,34 +3261,104 @@ _ppdCreateFromIPP2(
   }
 
  /*
-  * Standard stuff for PPD file...
+  * Get a sanitized make and model...
   */
 
-  cupsFilePuts(fp, "*PPD-Adobe: \"4.3\"\n");
-  cupsFilePuts(fp, "*FormatVersion: \"4.3\"\n");
-  cupsFilePrintf(fp, "*FileVersion: \"%d.%d\"\n", CUPS_VERSION_MAJOR, CUPS_VERSION_MINOR);
-  cupsFilePuts(fp, "*LanguageVersion: English\n");
-  cupsFilePuts(fp, "*LanguageEncoding: ISOLatin1\n");
-  cupsFilePuts(fp, "*PSVersion: \"(3010.000) 0\"\n");
-  cupsFilePuts(fp, "*LanguageLevel: \"3\"\n");
-  cupsFilePuts(fp, "*FileSystem: False\n");
-  cupsFilePuts(fp, "*PCFileName: \"ippeve.ppd\"\n");
+  if ((attr = ippFindAttribute(supported, "printer-make-and-model", IPP_TAG_TEXT)) != NULL && ippValidateAttribute(attr))
+  {
+   /*
+    * Sanitize the model name to only contain PPD-safe characters.
+    */
 
-  if ((attr = ippFindAttribute(supported, "printer-make-and-model", IPP_TAG_TEXT)) != NULL)
     strlcpy(make, ippGetString(attr, 0, NULL), sizeof(make));
+
+    for (mptr = make; *mptr; mptr ++)
+    {
+      if (*mptr < ' ' || *mptr >= 127 || *mptr == '\"')
+      {
+       /*
+	* Truncate the make and model on the first bad character...
+	*/
+
+	*mptr = '\0';
+	break;
+      }
+    }
+
+    while (mptr > make)
+    {
+     /*
+      * Strip trailing whitespace...
+      */
+
+      mptr --;
+      if (*mptr == ' ')
+	*mptr = '\0';
+    }
+
+    if (!make[0])
+    {
+     /*
+      * Use a default make and model if nothing remains...
+      */
+
+      strlcpy(make, "Unknown", sizeof(make));
+    }
+  }
   else
-    strlcpy(make, "Unknown Printer", sizeof(make));
+  {
+   /*
+    * Use a default make and model...
+    */
+
+    strlcpy(make, "Unknown", sizeof(make));
+  }
 
   if (!_cups_strncasecmp(make, "Hewlett Packard ", 16) || !_cups_strncasecmp(make, "Hewlett-Packard ", 16))
   {
+   /*
+    * Normalize HP printer make and model...
+    */
+
     model = make + 16;
     strlcpy(make, "HP", sizeof(make));
+
+    if (!_cups_strncasecmp(model, "HP ", 3))
+      model += 3;
+  }
+  else if ((mptr = strchr(make, ' ')) != NULL)
+  {
+   /*
+    * Separate "MAKE MODEL"...
+    */
+
+    while (*mptr && *mptr == ' ')
+      *mptr++ = '\0';
+
+    model = mptr;
   }
-  else if ((model = strchr(make, ' ')) != NULL)
-    *model++ = '\0';
   else
-    model = make;
+  {
+   /*
+    * No separate model name...
+    */
+
+    model = "Printer";
+  }
 
+ /*
+  * Standard stuff for PPD file...
+  */
+
+  cupsFilePuts(fp, "*PPD-Adobe: \"4.3\"\n");
+  cupsFilePuts(fp, "*FormatVersion: \"4.3\"\n");
+  cupsFilePrintf(fp, "*FileVersion: \"%d.%d\"\n", CUPS_VERSION_MAJOR, CUPS_VERSION_MINOR);
+  cupsFilePuts(fp, "*LanguageVersion: English\n");
+  cupsFilePuts(fp, "*LanguageEncoding: ISOLatin1\n");
+  cupsFilePuts(fp, "*PSVersion: \"(3010.000) 0\"\n");
+  cupsFilePuts(fp, "*LanguageLevel: \"3\"\n");
+  cupsFilePuts(fp, "*FileSystem: False\n");
+  cupsFilePuts(fp, "*PCFileName: \"ippeve.ppd\"\n");
   cupsFilePrintf(fp, "*Manufacturer: \"%s\"\n", make);
   cupsFilePrintf(fp, "*ModelName: \"%s\"\n", model);
   cupsFilePrintf(fp, "*Product: \"(%s)\"\n", model);
@@ -3317,13 +3388,13 @@ _ppdCreateFromIPP2(
   }
   cupsFilePuts(fp, "\"\n");
 
-  if ((attr = ippFindAttribute(supported, "printer-more-info", IPP_TAG_URI)) != NULL)
+  if ((attr = ippFindAttribute(supported, "printer-more-info", IPP_TAG_URI)) != NULL && ippValidateAttribute(attr))
     cupsFilePrintf(fp, "*APSupplies: \"%s\"\n", ippGetString(attr, 0, NULL));
 
-  if ((attr = ippFindAttribute(supported, "printer-charge-info-uri", IPP_TAG_URI)) != NULL)
+  if ((attr = ippFindAttribute(supported, "printer-charge-info-uri", IPP_TAG_URI)) != NULL && ippValidateAttribute(attr))
     cupsFilePrintf(fp, "*cupsChargeInfoURI: \"%s\"\n", ippGetString(attr, 0, NULL));
 
-  if ((attr = ippFindAttribute(supported, "printer-strings-uri", IPP_TAG_URI)) != NULL)
+  if ((attr = ippFindAttribute(supported, "printer-strings-uri", IPP_TAG_URI)) != NULL && ippValidateAttribute(attr))
   {
     http_t	*http = NULL;		/* Connection to printer */
     char	stringsfile[1024];	/* Temporary strings file */
@@ -3367,7 +3438,7 @@ _ppdCreateFromIPP2(
 
 	  response = cupsDoRequest(http, request, resource);
 
-	  if ((attr = ippFindAttribute(response, "printer-strings-uri", IPP_TAG_URI)) != NULL)
+	  if ((attr = ippFindAttribute(response, "printer-strings-uri", IPP_TAG_URI)) != NULL && ippValidateAttribute(attr))
 	    cupsFilePrintf(fp, "*cupsStringsURI %s: \"%s\"\n", keyword, ippGetString(attr, 0, NULL));
 
 	  ippDelete(response);
@@ -3389,10 +3460,10 @@ _ppdCreateFromIPP2(
   if (ippGetBoolean(ippFindAttribute(supported, "job-accounting-user-id-supported", IPP_TAG_BOOLEAN), 0))
     cupsFilePuts(fp, "*cupsJobAccountingUserId: True\n");
 
-  if ((attr = ippFindAttribute(supported, "printer-privacy-policy-uri", IPP_TAG_URI)) != NULL)
+  if ((attr = ippFindAttribute(supported, "printer-privacy-policy-uri", IPP_TAG_URI)) != NULL && ippValidateAttribute(attr))
     cupsFilePrintf(fp, "*cupsPrivacyURI: \"%s\"\n", ippGetString(attr, 0, NULL));
 
-  if ((attr = ippFindAttribute(supported, "printer-mandatory-job-attributes", IPP_TAG_KEYWORD)) != NULL)
+  if ((attr = ippFindAttribute(supported, "printer-mandatory-job-attributes", IPP_TAG_KEYWORD)) != NULL && ippValidateAttribute(attr))
   {
     char	prefix = '\"';		// Prefix for string
 
@@ -3410,7 +3481,7 @@ _ppdCreateFromIPP2(
     cupsFilePuts(fp, "\"\n");
   }
 
-  if ((attr = ippFindAttribute(supported, "printer-requested-job-attributes", IPP_TAG_KEYWORD)) != NULL)
+  if ((attr = ippFindAttribute(supported, "printer-requested-job-attributes", IPP_TAG_KEYWORD)) != NULL && ippValidateAttribute(attr))
   {
     char	prefix = '\"';		// Prefix for string
 
@@ -3973,18 +4044,16 @@ _ppdCreateFromIPP2(
 	cupsFilePrintf(fp, "*DefaultInputSlot: %s\n", ppdname);
 
       for (j = 0; j < (int)(sizeof(sources) / sizeof(sources[0])); j ++)
+      {
         if (!strcmp(sources[j], keyword))
 	{
 	  snprintf(msgid, sizeof(msgid), "media-source.%s", keyword);
 
-	  if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	    if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	      msgstr = keyword;
-
 	  cupsFilePrintf(fp, "*InputSlot %s: \"<</MediaPosition %d>>setpagedevice\"\n", ppdname, j);
-	  cupsFilePrintf(fp, "*%s.InputSlot %s/%s: \"\"\n", lang->language, ppdname, msgstr);
+	  ppd_put_string(fp, lang, strings, "InputSlot", ppdname, msgid);
 	  break;
 	}
+      }
     }
     cupsFilePuts(fp, "*CloseUI: *InputSlot\n");
   }
@@ -4010,12 +4079,9 @@ _ppdCreateFromIPP2(
       pwg_ppdize_name(keyword, ppdname, sizeof(ppdname));
 
       snprintf(msgid, sizeof(msgid), "media-type.%s", keyword);
-      if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	  msgstr = keyword;
 
       cupsFilePrintf(fp, "*MediaType %s: \"<</MediaType(%s)>>setpagedevice\"\n", ppdname, ppdname);
-      cupsFilePrintf(fp, "*%s.MediaType %s/%s: \"\"\n", lang->language, ppdname, msgstr);
+      ppd_put_string(fp, lang, strings, "MediaType", ppdname, msgid);
     }
     cupsFilePuts(fp, "*CloseUI: *MediaType\n");
   }
@@ -4476,12 +4542,9 @@ _ppdCreateFromIPP2(
       pwg_ppdize_name(keyword, ppdname, sizeof(ppdname));
 
       snprintf(msgid, sizeof(msgid), "output-bin.%s", keyword);
-      if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	  msgstr = keyword;
 
       cupsFilePrintf(fp, "*OutputBin %s: \"\"\n", ppdname);
-      cupsFilePrintf(fp, "*%s.OutputBin %s/%s: \"\"\n", lang->language, ppdname, msgstr);
+      ppd_put_string(fp, lang, strings, "OutputBin", ppdname, msgid);
 
       if ((tray_ptr = ippGetOctetString(trays, i, &tray_len)) != NULL)
       {
@@ -4600,9 +4663,6 @@ _ppdCreateFromIPP2(
         cupsArrayAdd(names, (char *)keyword);
 
 	snprintf(msgid, sizeof(msgid), "finishings.%d", value);
-	if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	  if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	    msgstr = keyword;
 
         if (value >= IPP_FINISHINGS_NONE && value <= IPP_FINISHINGS_LAMINATE)
           ppd_keyword = base_keywords[value - IPP_FINISHINGS_NONE];
@@ -4617,7 +4677,7 @@ _ppdCreateFromIPP2(
           continue;
 
 	cupsFilePrintf(fp, "*StapleLocation %s: \"\"\n", ppd_keyword);
-	cupsFilePrintf(fp, "*%s.StapleLocation %s/%s: \"\"\n", lang->language, ppd_keyword, msgstr);
+	ppd_put_string(fp, lang, strings, "StapleLocation", ppd_keyword, msgid);
 	cupsFilePrintf(fp, "*cupsIPPFinishings %d/%s: \"*StapleLocation %s\"\n", value, keyword, ppd_keyword);
       }
 
@@ -4680,9 +4740,6 @@ _ppdCreateFromIPP2(
         cupsArrayAdd(names, (char *)keyword);
 
 	snprintf(msgid, sizeof(msgid), "finishings.%d", value);
-	if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	  if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	    msgstr = keyword;
 
         if (value >= IPP_FINISHINGS_NONE && value <= IPP_FINISHINGS_LAMINATE)
           ppd_keyword = base_keywords[value - IPP_FINISHINGS_NONE];
@@ -4697,7 +4754,7 @@ _ppdCreateFromIPP2(
           continue;
 
 	cupsFilePrintf(fp, "*FoldType %s: \"\"\n", ppd_keyword);
-	cupsFilePrintf(fp, "*%s.FoldType %s/%s: \"\"\n", lang->language, ppd_keyword, msgstr);
+	ppd_put_string(fp, lang, strings, "FoldType", ppd_keyword, msgid);
 	cupsFilePrintf(fp, "*cupsIPPFinishings %d/%s: \"*FoldType %s\"\n", value, keyword, ppd_keyword);
       }
 
@@ -4768,9 +4825,6 @@ _ppdCreateFromIPP2(
         cupsArrayAdd(names, (char *)keyword);
 
 	snprintf(msgid, sizeof(msgid), "finishings.%d", value);
-	if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	  if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	    msgstr = keyword;
 
         if (value >= IPP_FINISHINGS_NONE && value <= IPP_FINISHINGS_LAMINATE)
           ppd_keyword = base_keywords[value - IPP_FINISHINGS_NONE];
@@ -4785,7 +4839,7 @@ _ppdCreateFromIPP2(
           continue;
 
 	cupsFilePrintf(fp, "*PunchMedia %s: \"\"\n", ppd_keyword);
-	cupsFilePrintf(fp, "*%s.PunchMedia %s/%s: \"\"\n", lang->language, ppd_keyword, msgstr);
+	ppd_put_string(fp, lang, strings, "PunchMedia", ppd_keyword, msgid);
 	cupsFilePrintf(fp, "*cupsIPPFinishings %d/%s: \"*PunchMedia %s\"\n", value, keyword, ppd_keyword);
       }
 
@@ -4856,9 +4910,6 @@ _ppdCreateFromIPP2(
         cupsArrayAdd(names, (char *)keyword);
 
 	snprintf(msgid, sizeof(msgid), "finishings.%d", value);
-	if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	  if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	    msgstr = keyword;
 
         if (value == IPP_FINISHINGS_TRIM)
           ppd_keyword = "Auto";
@@ -4866,7 +4917,7 @@ _ppdCreateFromIPP2(
 	  ppd_keyword = trim_keywords[value - IPP_FINISHINGS_TRIM_AFTER_PAGES];
 
 	cupsFilePrintf(fp, "*CutMedia %s: \"\"\n", ppd_keyword);
-	cupsFilePrintf(fp, "*%s.CutMedia %s/%s: \"\"\n", lang->language, ppd_keyword, msgstr);
+	ppd_put_string(fp, lang, strings, "CutMedia", ppd_keyword, msgid);
 	cupsFilePrintf(fp, "*cupsIPPFinishings %d/%s: \"*CutMedia %s\"\n", value, keyword, ppd_keyword);
       }
 
@@ -4905,12 +4956,11 @@ _ppdCreateFromIPP2(
 
       cupsArrayAdd(templates, (void *)keyword);
 
+      pwg_ppdize_name(keyword, ppdname, sizeof(ppdname));
+
       snprintf(msgid, sizeof(msgid), "finishing-template.%s", keyword);
-      if ((msgstr = _cupsLangString(lang, msgid)) == msgid || !strcmp(msgid, msgstr))
-	if ((msgstr = _cupsMessageLookup(strings, msgid)) == msgid)
-	  msgstr = keyword;
 
-      cupsFilePrintf(fp, "*cupsFinishingTemplate %s: \"\n", keyword);
+      cupsFilePrintf(fp, "*cupsFinishingTemplate %s: \"\n", ppdname);
       for (finishing_attr = ippFirstAttribute(finishing_col); finishing_attr; finishing_attr = ippNextAttribute(finishing_col))
       {
         if (ippGetValueTag(finishing_attr) == IPP_TAG_BEGIN_COLLECTION)
@@ -4923,7 +4973,7 @@ _ppdCreateFromIPP2(
 	}
       }
       cupsFilePuts(fp, "\"\n");
-      cupsFilePrintf(fp, "*%s.cupsFinishingTemplate %s/%s: \"\"\n", lang->language, keyword, msgstr);
+      ppd_put_string(fp, lang, strings, "cupsFinishingTemplate", ppdname, msgid);
       cupsFilePuts(fp, "*End\n");
     }
 
@@ -4959,9 +5009,8 @@ _ppdCreateFromIPP2(
     {
       ipp_t	*preset = ippGetCollection(attr, i);
 					/* Preset collection */
-      const char *preset_name = ippGetString(ippFindAttribute(preset, "preset-name", IPP_TAG_ZERO), 0, NULL),
+      const char *preset_name = ippGetString(ippFindAttribute(preset, "preset-name", IPP_TAG_ZERO), 0, NULL);
 					/* Preset name */
-		*localized_name;	/* Localized preset name */
       ipp_attribute_t *member;		/* Member attribute in preset */
       const char *member_name;		/* Member attribute name */
       char      	member_value[256];	/* Member attribute value */
@@ -4969,7 +5018,8 @@ _ppdCreateFromIPP2(
       if (!preset || !preset_name)
         continue;
 
-      cupsFilePrintf(fp, "*APPrinterPreset %s: \"\n", preset_name);
+      pwg_ppdize_name(preset_name, ppdname, sizeof(ppdname));
+      cupsFilePrintf(fp, "*APPrinterPreset %s: \"\n", ppdname);
       for (member = ippFirstAttribute(preset); member; member = ippNextAttribute(preset))
       {
         member_name = ippGetName(member);
@@ -5010,7 +5060,10 @@ _ppdCreateFromIPP2(
             fin_col = ippGetCollection(member, i);
 
             if ((keyword = ippGetString(ippFindAttribute(fin_col, "finishing-template", IPP_TAG_ZERO), 0, NULL)) != NULL)
-              cupsFilePrintf(fp, "*cupsFinishingTemplate %s\n", keyword);
+            {
+              pwg_ppdize_name(keyword, ppdname, sizeof(ppdname));
+              cupsFilePrintf(fp, "*cupsFinishingTemplate %s\n", ppdname);
+            }
           }
         }
         else if (!strcmp(member_name, "media"))
@@ -5037,13 +5090,13 @@ _ppdCreateFromIPP2(
           if ((keyword = ippGetString(ippFindAttribute(media_col, "media-source", IPP_TAG_ZERO), 0, NULL)) != NULL)
           {
             pwg_ppdize_name(keyword, ppdname, sizeof(ppdname));
-            cupsFilePrintf(fp, "*InputSlot %s\n", keyword);
+            cupsFilePrintf(fp, "*InputSlot %s\n", ppdname);
 	  }
 
           if ((keyword = ippGetString(ippFindAttribute(media_col, "media-type", IPP_TAG_ZERO), 0, NULL)) != NULL)
           {
             pwg_ppdize_name(keyword, ppdname, sizeof(ppdname));
-            cupsFilePrintf(fp, "*MediaType %s\n", keyword);
+            cupsFilePrintf(fp, "*MediaType %s\n", ppdname);
 	  }
         }
         else if (!strcmp(member_name, "print-quality"))
@@ -5088,8 +5141,9 @@ _ppdCreateFromIPP2(
 
       cupsFilePuts(fp, "\"\n*End\n");
 
-      if ((localized_name = _cupsMessageLookup(strings, preset_name)) != preset_name)
-        cupsFilePrintf(fp, "*%s.APPrinterPreset %s/%s: \"\"\n", lang->language, preset_name, localized_name);
+      snprintf(msgid, sizeof(msgid), "preset-name.%s", preset_name);
+      pwg_ppdize_name(preset_name, ppdname, sizeof(ppdname));
+      ppd_put_string(fp, lang, strings, "APPrinterPreset", ppdname, msgid);
     }
   }
 
@@ -5361,6 +5415,43 @@ cups_get_url(http_t     **http,		/* IO -
 
 
 /*
+ * 'ppd_put_strings()' - Write localization attributes to a PPD file.
+ */
+
+static void
+ppd_put_string(cups_file_t  *fp,	/* I - PPD file */
+               cups_lang_t  *lang,	/* I - Language */
+               cups_array_t *strings,	/* I - Strings */
+	       const char   *ppd_option,/* I - PPD option */
+	       const char   *ppd_choice,/* I - PPD choice */
+	       const char   *pwg_msgid)	/* I - PWG message ID */
+{
+  const char	*text;			/* Localized text */
+
+
+  if ((text = _cupsLangString(lang, pwg_msgid)) == pwg_msgid || !strcmp(pwg_msgid, text))
+  {
+    if ((text = _cupsMessageLookup(strings, pwg_msgid)) == pwg_msgid)
+      return;
+  }
+
+  // Add the first line of localized text...
+  cupsFilePrintf(fp, "*%s.%s %s/", lang->language, ppd_option, ppd_choice);
+  while (*text && *text != '\n')
+  {
+    // Escape ":" and "<"...
+    if (*text == ':' || *text == '<')
+      cupsFilePrintf(fp, "<%02X>", *text);
+    else
+      cupsFilePutChar(fp, *text);
+
+    text ++;
+  }
+  cupsFilePuts(fp, ": \"\"\n");
+}
+
+
+/*
  * 'pwg_add_finishing()' - Add a finishings value.
  */
 
@@ -5473,7 +5564,7 @@ pwg_ppdize_name(const char *ipp,	/* I - 
 	*end;				/* End of name buffer */
 
 
-  if (!ipp)
+  if (!ipp || !_cups_isalnum(*ipp))
   {
     *name = '\0';
     return;
@@ -5488,8 +5579,14 @@ pwg_ppdize_name(const char *ipp,	/* I - 
       ipp ++;
       *ptr++ = (char)toupper(*ipp++ & 255);
     }
-    else
+    else if (*ipp == '_' || *ipp == '.' || *ipp == '-' || _cups_isalnum(*ipp))
+    {
       *ptr++ = *ipp++;
+    }
+    else
+    {
+      ipp ++;
+    }
   }
 
   *ptr = '\0';
