# $NetBSD: defs.SunOS.mk,v 1.1 2001/06/12 12:49:55 jlam Exp $
#
# Variable definitions for the SunOS/Solaris operating system.

AWK?=		/usr/bin/nawk
BASENAME?=	/usr/bin/basename
CAT?=		/usr/bin/cat
CHMOD?=		/usr/bin/chmod
CHOWN?=		/usr/bin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/usr/bin/cp
CUT?=		/usr/bin/cut
DC?=		/usr/bin/dc
ECHO?=		/usr/ucb/echo
EGREP?=		/usr/xpg4/bin/egrep
FALSE?=		/usr/bin/false
FILE?=		/usr/bin/file
FIND?=		/usr/bin/find
GREP?=		/usr/bin/grep
GTAR?=		${ZOULARISBASE}/bin/tar
.if exists(/usr/bin/gzip)
GUNZIP_CMD?=	/usr/bin/gunzip -f
GZCAT?=		/usr/bin/gzcat
GZIP?=		-9
GZIP_CMD?=	/usr/bin/gzip -nf ${GZIP}
.else
GUNZIP_CMD?=	${LOCALBASE}/bin/gunzip -f
GZCAT?=		${LOCALBASE}/bin/zcat
GZIP?=		-9
GZIP_CMD?=	${LOCALBASE}/bin/gzip -nf ${GZIP}
.endif
HEAD?=		/usr/bin/head
ID?=		/usr/xpg4/bin/id
LDCONFIG?=	/usr/bin/true
LN?=		/usr/bin/ln
LS?=		/usr/bin/ls
MKDIR?=		/usr/bin/mkdir -p
MTREE?=		${ZOULARISBASE}/bin/mtree
MV?=		/usr/bin/mv
.if exists(/usr/bin/gpatch)
PATCH?=		/usr/bin/gpatch -b
.else
PATCH?=		${LOCALBASE}/bin/patch -b
.endif
PAX?=		/bin/pax
PKGLOCALEDIR?=	lib
RM?=		/usr/bin/rm
RMDIR?=		/usr/bin/rmdir
SED?=		/usr/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/ksh
SU?=		/usr/bin/su
TAIL?=		/usr/xpg4/bin/tail
TEST?=		/usr/bin/test
TOUCH?=		/usr/bin/touch
TR?=		/usr/bin/tr
TRUE?=		/usr/bin/true
TYPE?=		/usr/bin/type
XARGS?=		/usr/bin/xargs
