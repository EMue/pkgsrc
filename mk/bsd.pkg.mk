#	$NetBSD: bsd.pkg.mk,v 1.550 2000/08/24 23:29:26 jlam Exp $
#
# This file is in the public domain.
#
# This file is derived from bsd.port.mk - 940820 Jordan K. Hubbard.
#
# Please see the NetBSD packages(7) manual page for details on the
# that variables used in this make file template.

# Default sequence for "all" is:  fetch checksum extract patch configure build
#
# Please read the comments in the targets section below, you
# should be able to use the pre-* or post-* targets/scripts
# (which are available for every stage except checksum) or
# override the do-* targets to do pretty much anything you want.
#
# NEVER override the "regular" targets unless you want to open
# a major can of worms.

##### Include any preferences, if not already included, and common definitions
.include "../../mk/bsd.prefs.mk"

##### Some overrides of defaults below on a per-OS basis.
.if (${OPSYS} == "NetBSD")
LOCALBASE?=		${DESTDIR}/usr/pkg
.elif (${OPSYS} == "SunOS")
DEF_UMASK?=		022
X11BASE?=		${DESTDIR}/usr/openwin
.elif (${OPSYS} == "Linux")
DEF_UMASK?=		022
NOMANCOMPRESS?=		yes
.endif

DEF_UMASK?=		0022
CLEANDEPENDS?=		NO
DEINSTALLDEPENDS?=	NO	# add -R to pkg_delete
REINSTALL?=		NO	# reinstall upon update
NOCLEAN?=		NO	# don't clean up after update

LOCALBASE?=		${DESTDIR}/usr/local
X11BASE?=		${DESTDIR}/usr/X11R6
CROSSBASE?=		${LOCALBASE}/cross

PKGSRCDIR?=		${.CURDIR:C|/[^/]*/[^/]*$||}
PKGPATH?=		${.CURDIR:C|.*/([^/]*/[^/]*)$|\1|}
PKGBASE?=		${PKGNAME:C/-[^-]*$//}
PKGVERSION?=		${PKGNAME:C/^.*-//}
PKGWILDCARD=		${PKGBASE}-[0-9]*

DISTDIR?=		${PKGSRCDIR}/distfiles
_DISTDIR?=		${DISTDIR}/${DIST_SUBDIR}
PACKAGES?=		${PKGSRCDIR}/packages
TEMPLATES?=		${PKGSRCDIR}/templates

PATCHDIR?=		${.CURDIR}/patches
SCRIPTDIR?=		${.CURDIR}/scripts
FILESDIR?=		${.CURDIR}/files
PKGDIR?=		${.CURDIR}/pkg

.if defined(USE_JAVA)
BUILD_DEFS+=		PKG_JVM JAVA_HOME
.if !defined(PKG_JVM)
.if ${MACHINE_PLATFORM:MNetBSD-*-i386} != ""
PKG_JVM?=		jdk
.else
PKG_JVM?=		kaffe
.endif
.endif
.if ${PKG_JVM} == "jdk"
DEPENDS+=		jdk-1.1.*:../../lang/jdk
.if defined(JDK_HOME)
JAVA_HOME?=		${JDK_HOME}
.else
JAVA_HOME?=		${LOCALBASE}/java
.endif
.elif ${PKG_JVM} == "kaffe"
DEPENDS+=		kaffe-[0-9]*:../../lang/kaffe
JAVA_HOME?=		${LOCALBASE}/kaffe
.endif
CLASSPATH?=		${JAVA_HOME}/lib/classes.zip:.
PATH:=			${PATH}:${JAVA_HOME}/bin
MAKE_ENV+=		CLASSPATH=${CLASSPATH} JAVA_HOME=${JAVA_HOME}
CONFIGURE_ENV+=		CLASSPATH=${CLASSPATH} JAVA_HOME=${JAVA_HOME}
SCRIPTS_ENV+=		CLASSPATH=${CLASSPATH} JAVA_HOME=${JAVA_HOME}
.endif

# set X11PREFIX to reflect installed dir of X11 packages
.if exists(${X11BASE}/lib/X11/config/xpkgwedge.def)
X11PREFIX=		${LOCALBASE}
.else
X11PREFIX=		${X11BASE}
.endif

.if defined(USE_MOTIF12)
USE_MOTIF=		# defined
.endif

.if defined(USE_MOTIF)
.if ${OPSYS} == "SunOS"
MOTIFBASE?=		/usr/dt
.elif exists(${X11BASE}/include/Xm/Xm.h)
.if defined(USE_MOTIF12) && exists(${X11BASE}/include/Xm/Gadget.h)
MOTIFBASE?=		${X11PREFIX}/LessTif/Motif1.2
.else
MOTIFBASE?=		${X11BASE}
.endif
.elif defined(USE_MOTIF12)
MOTIFBASE?=		${X11PREFIX}/LessTif/Motif1.2
.else
MOTIFBASE?=		${X11PREFIX}
.endif
.endif  # USE_MOTIF

.if defined(USE_IMAKE) || defined(USE_MOTIF) || defined(USE_X11BASE)
PREFIX=			${X11PREFIX}
.elif defined(USE_CROSSBASE)
PREFIX=			${CROSSBASE}
NO_MTREE=		yes
.else
PREFIX=			${LOCALBASE}
.endif

.if defined(USE_GMAKE)
BUILD_DEPENDS+=		${GMAKE}:../../devel/gmake
MAKE_PROGRAM=		${GMAKE}
GMAKE?=			gmake
.else
MAKE_PROGRAM=		${MAKE}
.endif

.if defined(USE_KERBEROS)
RESTRICTED?=		uses Kerberos encryption code
BUILD_DEFS+=		KERBEROS
.endif

.if defined(USE_PERL5)
DEPENDS+=		perl-*:../../lang/perl5
.endif

.if defined(USE_FORTRAN)
.if !exists(/usr/bin/f77)
PKG_FC?=		f2c-f77
.endif
# it is anticipated that once /usr/bin/f77 is more stable that the following
# default will be changed to f77.  However, in the case where there is no
# /usr/bin/f77, the default will remain as f2c-f77.
PKG_FC?=		f2c-f77
.if  (${PKG_FC} == "f2c-f77")
BUILD_DEPENDS+=       f2c-f77:../../lang/f2c
.endif
FC=             ${PKG_FC}
F77=            ${PKG_FC}
MAKE_ENV+=	F77="${F77}"
MAKE_ENV+=	FC="${FC}"
.endif

.if defined(INFO_FILES)
USE_GTEXINFO=		yes
.endif

.if defined(USE_CURSES) && !defined(NEED_NCURSES)
.if ${OPSYS} == "NetBSD"
GOOD_CURSES=    1.4[YZ] 1.4Z[A-D] 1.[5-9]*
NEED_NCURSES=	YES
.for PATTERN in ${GOOD_CURSES}
.if ${OS_VERSION:M${PATTERN}} != ""
NEED_NCURSES=   NO
.endif
.endfor
.else
NEED_NCURSES=	NO
.endif
# do _not_ pass NEED_NCURSES flag down, or we end up with recursive
# dependency of ncurses on itself on <1.4Y.
# MAKEFLAGS+=	NEED_NCURSES=${NEED_NCURSES}
.endif

.if defined(NEED_NCURSES) && ${NEED_NCURSES} == "YES"
DEPENDS+=		ncurses>=5.0:../../devel/ncurses
.endif

.if defined(USE_GTEXINFO) && !exists(/usr/bin/install-info)
DEPENDS+=		gtexinfo-3.12:../../devel/gtexinfo
.endif

.if defined(USE_LIBTOOL)
LIBTOOL=		${LOCALBASE}/bin/libtool
# XXX: actually, here we would need something like
# BUILD_DEPENDS+=libtool>1.3.5nb3:../../devel/libtool
.if make(install-run-depends)
DEPENDS+=		libtool>1.3.5nb3:../../devel/libtool
.endif
.endif

.if defined(USE_LIBTOOL)
CONFIGURE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
MAKE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
.endif

.if defined(USE_SSL)
.if exists(/usr/include/openssl/ssl.h)
SSLBASE=	/usr
.else
DEPENDS+=	openssl>=0.9.5a:../../security/openssl
SSLBASE=	${LOCALBASE}
.endif
BUILD_DEFS+=	SSLBASE
.endif

.if defined(USE_XAW)
XAW_TYPE?=		standard
.if ${XAW_TYPE} == "xpm"
DEPENDS+=		Xaw-Xpm-1.1:../../x11/Xaw-Xpm
.elif ${XAW_TYPE} == "3d"
DEPENDS+=		Xaw3d-1.5:../../x11/Xaw3d
.endif
.endif

# Don't change these!!!  These names are built into the _TARGET_USE macro,
# there is no way to refer to them cleanly from within the macro AFAIK.
EXTRACT_COOKIE=		${WRKDIR}/.extract_done
CONFIGURE_COOKIE=	${WRKDIR}/.configure_done
INSTALL_COOKIE=		${WRKDIR}/.install_done
BUILD_COOKIE=		${WRKDIR}/.build_done
PATCH_COOKIE=		${WRKDIR}/.patch_done
PACKAGE_COOKIE=		${WRKDIR}/.package_done

# Miscellaneous overridable commands:
SHCOMMENT?=		${ECHO_MSG} >/dev/null '***'
XMKMF?=			xmkmf -a
.if exists(/sbin/md5)
MD5?=			/sbin/md5
.elif exists(/bin/md5)
MD5?=			/bin/md5
.elif exists(/usr/bin/md5)
MD5?=			/usr/bin/md5
.elif exists(${LOCALBASE}/bsd/bin/md5)
MD5?=			${LOCALBASE}/bsd/bin/md5
.else
MD5?=			md5
.endif
MD5_FILE?=		${FILESDIR}/md5
PATCH_SUM_FILE?=	${FILESDIR}/patch-sum

.if exists(/usr/bin/m4)
M4?=			/usr/bin/m4
.endif

.if defined(USE_MOTIF) || defined(USE_X11BASE) || defined(USE_X11)
.if defined(USE_MOTIF)
LDFLAGS+=		-Wl,-R${MOTIFBASE}/lib -L${MOTIFBASE}/lib
.endif
LDFLAGS+=		-Wl,-R${X11BASE}/lib -L${X11BASE}/lib
.endif
LDFLAGS+=		-Wl,-R${LOCALBASE}/lib -L${LOCALBASE}/lib
MAKE_ENV+=		LDFLAGS="${LDFLAGS}"
CONFIGURE_ENV+=		LDFLAGS="${LDFLAGS}" M4="${M4}" YACC="${YACC}"

MAKE_FLAGS?=
MAKEFILE?=		Makefile
MAKE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin PREFIX=${PREFIX} LOCALBASE=${LOCALBASE} X11BASE=${X11BASE} CFLAGS="${CFLAGS}"

.if defined(USE_MOTIF)
MAKE_ENV+=		MOTIFLIB="${MOTIFLIB}"
.endif

.if exists(${LOCALBASE}/bsd/bin/ftp)			# Zoularis
FETCH_CMD?=		${LOCALBASE}/bsd/bin/ftp
.else
FETCH_CMD?=		/usr/bin/ftp
.endif

TOUCH_FLAGS?=		-f

PATCH_STRIP?=		-p0
PATCH_DIST_STRIP?=	-p0
.if defined(PATCH_DEBUG) || defined(PKG_VERBOSE)
PATCH_DEBUG_TMP=	yes
PATCH_ARGS?=		-d ${WRKSRC} -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} -E ${PATCH_DIST_STRIP}
.else
PATCH_DEBUG_TMP=	no
PATCH_ARGS?=		-d ${WRKSRC} --forward --quiet -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} --forward --quiet -E ${PATCH_DIST_STRIP}
.endif
.if defined(BATCH)
PATCH_ARGS+=		--batch
PATCH_DIST_ARGS+=	--batch
.endif
.if defined(PKG_DEVELOPER)
PATCH_FUZZ_FACTOR?=	-F0			# Force zero fuzz
.endif

.if defined(PATCH_CHECK_ONLY)
PATCH_ARGS+=		-C
PATCH_DIST_ARGS+=	-C
.endif

# If the distfile has a tar.bz2 suffix, use bzcat in preference to gzcat,
# pulling in the "bzip2" package if necessary. [Note: this is only for
# the benefit of pre 1.5 NetBSD systems. "gzcat" on newer systems happily
# decodes bzip2.] Do likewise for ".zip" and ".lha" distfiles.
EXTRACT_SUFX?=		.tar.gz
.if ${EXTRACT_SUFX} == ".tar.bz2"
.if exists(/usr/bin/bzcat)
BZCAT=			/usr/bin/bzcat
.else
BZCAT=			${LOCALBASE}/bin/bzcat
BUILD_DEPENDS+=		${BZCAT}:../../archivers/bzip2
.endif # !exists bzcat
DECOMPRESS_CMD?=	${BZCAT}
.elif ${EXTRACT_SUFX} == ".tar"
DECOMPRESS_CMD?=	${CAT}
.elif ${EXTRACT_SUFX} == ".zip"
BUILD_DEPENDS+=		unzip:../../archivers/unzip
EXTRACT_CMD?=		unzip -Laq ${DOWNLOADED_DISTFILE}
.elif ${EXTRACT_SUFX} == ".lzh"
BUILD_DEPENDS+=		lha:../../archivers/lha
EXTRACT_CMD?=		lha xq ${DOWNLOADED_DISTFILE}
.else
DECOMPRESS_CMD?=	${GZCAT}
.endif

# Also need bzip2 for PATCHFILES with .bz2 suffix.
.if defined(PATCHFILES)
.if ${PATCHFILES:E} == "bz2" && ${EXTRACT_SUFX} != ".tar.bz2"
.if exists(/usr/bin/bzcat)
BZCAT=			/usr/bin/bzcat
.else
BZCAT=			${LOCALBASE}/bin/bzcat
BUILD_DEPENDS+=		${BZCAT}:../../archivers/bzip2
.endif # !exists bzcat
.endif
.endif # defined(PATCHFILES)

# If this is empty, then everything gets extracted.
EXTRACT_ELEMENTS?=	

# If EXTRACT_USING_PAX is defined, use pax in preference to (GNU) tar,
# and append 2 tar blocks of zero bytes on the end, in case the archive
# was written with a buggy version of GNU tar.
.if defined(EXTRACT_USING_PAX)
EXTRACT_CMD?=		(${DECOMPRESS_CMD} ${DOWNLOADED_DISTFILE} ; dd if=/dev/zero bs=10k count=2) | ${PAX} -r ${EXTRACT_ELEMENTS}
.else
EXTRACT_CMD?=		${DECOMPRESS_CMD} ${DOWNLOADED_DISTFILE} | ${GTAR} -xf - ${EXTRACT_ELEMENTS}
.endif

# Figure out where the local mtree file is
.if !defined(MTREE_FILE)
.if defined(USE_IMAKE) || defined(USE_MOTIF) || defined(USE_X11BASE)
MTREE_FILE=	${PKGSRCDIR}/mk/${OPSYS}.x11.dist
.else
MTREE_FILE=	${PKGSRCDIR}/mk/${OPSYS}.pkg.dist
.endif
.endif # ! MTREE_FILE

MTREE_ARGS?=	-U -f ${MTREE_FILE} -d -e -p

# Debugging levels for this file, dependent on PKG_DEBUG_LEVEL definition
# 0 == normal, default, quiet operation
# 1 == all shell commands echoed before invocation
# 2 == shell "set -x" operation
PKG_DEBUG_LEVEL?=	0
_PKG_SILENT=		@
_PKG_DEBUG=		

.if ${PKG_DEBUG_LEVEL} > 0
_PKG_SILENT=	
.endif

.if ${PKG_DEBUG_LEVEL} > 1
_PKG_DEBUG=		set -x;
.endif

# If WRKOBJDIR is set, use that tree to build
.ifdef WRKOBJDIR
BUILD_ROOT=     	${WRKOBJDIR}
BUILD_DIR?=		${WRKOBJDIR}/${PKGPATH}
.else
BUILD_ROOT=     	${PKGSRCDIR}
BUILD_DIR?=		${.CURDIR}
.endif # WRKOBJDIR

# If OBJMACHINE is set, use ${MACHINE_ARCH} in the working directory name
.ifdef OBJMACHINE
WRKDIR_BASENAME?=	work.${MACHINE_ARCH}
.else
WRKDIR_BASENAME?=	work
.endif

.ifdef NO_WRKDIR
WRKDIR?=		${BUILD_DIR}
.else
WRKDIR?=		${BUILD_DIR}/${WRKDIR_BASENAME}
.endif # !NO_WRKDIR

.if defined(NO_WRKSUBDIR)
WRKSRC?=		${WRKDIR}
.else # NO_WRKSUBDIR
WRKSRC?=		${WRKDIR}/${DISTNAME}
.endif # NO_WRKSUBDIR

# A few aliases for *-install targets
INSTALL_PROGRAM?= \
	${INSTALL} ${COPY} ${STRIPFLAG} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_SCRIPT?= \
	${INSTALL} ${COPY} -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_DATA?= \
	${INSTALL} ${COPY} -o ${SHAREOWN} -g ${SHAREGRP} -m ${SHAREMODE}
INSTALL_MAN?= \
	${INSTALL} ${COPY} -o ${MANOWN} -g ${MANGRP} -m ${MANMODE}
INSTALL_PROGRAM_DIR?= \
	${INSTALL} -d -o ${BINOWN} -g ${BINGRP} -m ${BINMODE}
INSTALL_SCRIPT_DIR?= \
	${INSTALL_PROGRAM_DIR}
INSTALL_DATA_DIR?= \
	${INSTALL} -d -o ${SHAREOWN} -g ${SHAREGRP} -m ${BINMODE}
INSTALL_MAN_DIR?= \
	${INSTALL} -d -o ${MANOWN} -g ${MANGRP} -m ${BINMODE}

INSTALL_MACROS=	BSD_INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
			BSD_INSTALL_SCRIPT="${INSTALL_SCRIPT}" \
			BSD_INSTALL_DATA="${INSTALL_DATA}" \
			BSD_INSTALL_MAN="${INSTALL_MAN}" \
			BSD_INSTALL_PROGRAM_DIR="${INSTALL_PROGRAM_DIR}" \
			BSD_INSTALL_SCRIPT_DIR="${INSTALL_SCRIPT_DIR}" \
			BSD_INSTALL_DATA_DIR="${INSTALL_DATA_DIR}" \
			BSD_INSTALL_MAN_DIR="${INSTALL_MAN_DIR}"
MAKE_ENV+=	${INSTALL_MACROS}
SCRIPTS_ENV+=	${INSTALL_MACROS}

# The user can override the NO_PACKAGE by specifying this from
# the make command line
.if defined(FORCE_PACKAGE)
.undef NO_PACKAGE
.endif

COMMENT?=		${PKGDIR}/COMMENT
DESCR_SRC?=		${PKGDIR}/DESCR
DESCR=			${WRKDIR}/.DESCR
PLIST=			${WRKDIR}/.PLIST
DLIST=			${WRKDIR}/.DLIST
DDIR=			${WRKDIR}/.DDIR

# Set PLIST_SUBST to substitute "${variable}" to "value" in PLIST
PLIST_SUBST+=	OPSYS=${OPSYS}					\
		OS_VERSION=${OS_VERSION}			\
		MACHINE_ARCH=${MACHINE_ARCH}			\
		MACHINE_GNU_ARCH=${MACHINE_GNU_ARCH}		\
		MACHINE_GNU_PLATFORM=${MACHINE_GNU_PLATFORM}	\
		LOWER_VENDOR=${LOWER_VENDOR}			\
		LOWER_OPSYS=${LOWER_OPSYS}			\
		PKGNAME=${PKGNAME}

# Set INSTALL_FILE to be the name of any INSTALL file
.if !defined(INSTALL_FILE) && exists(${PKGDIR}/INSTALL)
INSTALL_FILE=		${PKGDIR}/INSTALL
.endif

# Set DEINSTALL_FILE to be the name of any DEINSTALL file
.if !defined(DEINSTALL_FILE) && exists(${PKGDIR}/DEINSTALL)
DEINSTALL_FILE=		${PKGDIR}/DEINSTALL
.endif

# Set REQ_FILE to be the name of any REQ file
.if !defined(REQ_FILE) && exists(${PKGDIR}/REQ)
REQ_FILE=		${PKGDIR}/REQ
.endif

# Set MESSAGE_FILE to be the name of any MESSAGE file
.if !defined(MESSAGE_FILE) && exists(${PKGDIR}/MESSAGE)
MESSAGE_FILE=		${PKGDIR}/MESSAGE
.endif

.if (${OPSYS} == "SunOS")
AWK?=		/usr/bin/nawk
BASENAME?=	/usr/bin/basename
CAT?=		/usr/bin/cat
CHMOD?=		/usr/bin/chmod
CHOWN?=		/usr/bin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/usr/bin/cp
CUT?=		/usr/bin/cut
ECHO?=		/usr/ucb/echo
EGREP?=		/usr/xpg4/bin/egrep
FALSE?=		/usr/bin/false
FILE?=		/usr/bin/file
FIND?=		/usr/bin/find
GREP?=		/usr/bin/grep
GTAR?=		${LOCALBASE}/bin/gtar
GUNZIP_CMD?=	${LOCALBASE}/bin/gunzip -f
GZCAT?=		${LOCALBASE}/bin/zcat
GZIP?=		-9
GZIP_CMD?=	${LOCALBASE}/bin/gzip -nf ${GZIP}
HEAD?=		/usr/bin/head
ID?=		/usr/xpg4/bin/id
IDENT?=		${LOCALBASE}/bin/ident
LDCONFIG?=	/usr/bin/true
LN?=		/usr/bin/ln
MKDIR?=		/usr/bin/mkdir -p
MTREE?=		${LOCALBASE}/bsd/bin/mtree
MV?=		/usr/bin/mv
PATCH?=		${LOCALBASE}/bin/patch -b
PAX?=		/bin/pax
PKG_TOOLS_BIN?= ${LOCALBASE}/bsd/bin
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
.elif (${OPSYS} == "Linux")
AWK?=		/usr/bin/awk
BASENAME?=	/bin/basename
CAT?=		/bin/cat
CHMOD?=		/bin/chmod
CHOWN?=		/usr/sbin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/bin/cp
CUT?=		/bin/cut
ECHO?=		/bin/echo
EGREP?=		/bin/egrep
FALSE?=		/bin/false
FILE?=		/usr/bin/file
FIND?=		/usr/bin/find
GREP?=		/bin/grep
GTAR?=		/bin/tar
GUNZIP_CMD?=	/usr/bin/gunzip -f
GZCAT?=		/bin/zcat
GZIP?=		-9
GZIP_CMD?=	/usr/bin/gzip -nf ${GZIP}
HEAD?=		/usr/bin/head
ID?=		/usr/bin/id
IDENT?=		/usr/bin/ident
LDCONFIG?=	/sbin/ldconfig
LN?=		/bin/ln
MKDIR?=		/bin/mkdir -p
MTREE?=		${LOCALBASE}/bsd/bin/mtree
MV?=		/bin/mv
PATCH?=		/usr/bin/patch
PAX?=		/usr/local/bsd/bin/pax
PKG_TOOLS_BIN?= ${LOCALBASE}/bsd/bin
RM?=		/bin/rm
RMDIR?=		/bin/rmdir
SED?=		/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/sh
SU?=		/bin/su
TAIL?=		/usr/bin/tail
TEST?=		/usr/bin/test
TOUCH?=		/bin/touch
TR?=		/usr/bin/tr
TRUE?=		/bin/true
TYPE?=		type
.else
AWK?=		/usr/bin/awk
BASENAME?=	/usr/bin/basename
CAT?=		/bin/cat
CHMOD?=		/bin/chmod
CHOWN?=		/usr/sbin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/bin/cp
CUT?=		/usr/bin/cut
ECHO?=		echo				# Shell builtin
EGREP?=		/usr/bin/egrep
FALSE?=		false				# Shell builtin
FILE?=		/usr/bin/file
FIND?=		/usr/bin/find
GREP?=		/usr/bin/grep
GTAR?=		/usr/bin/tar
GUNZIP_CMD?=	/usr/bin/gunzip -f
GZCAT?=		/usr/bin/gzcat
GZIP?=		-9
GZIP_CMD?=	/usr/bin/gzip -nf ${GZIP}
HEAD?=		/usr/bin/head
ID?=		/usr/bin/id
IDENT?=		/usr/bin/ident
LDCONFIG?=	/sbin/ldconfig
LN?=		/bin/ln
MKDIR?=		/bin/mkdir -p
MTREE?=		/usr/sbin/mtree
MV?=		/bin/mv
PATCH?=		/usr/bin/patch
PAX?=		/bin/pax
PKG_TOOLS_BIN?= /usr/sbin
RM?=		/bin/rm
RMDIR?=		/bin/rmdir
SED?=		/usr/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/sh
SU?=		/usr/bin/su
TAIL?=		/usr/bin/tail
TEST?=		test				# Shell builtin
TOUCH?=		/usr/bin/touch
TR?=		/usr/bin/tr
TRUE?=		true				# Shell builtin
TYPE?=		type				# Shell builtin
.endif # !SunOS

.if (defined(DESTDIR) && defined(PKGTOOLS_VERSION))
PKG_ADD?=	PKG_DBDIR=${PKG_DBDIR} ${PKG_TOOLS_BIN}/pkg_add
PKG_ADMIN?=	PKG_DBDIR=${PKG_DBDIR} ${PKG_TOOLS_BIN}/pkg_admin
PKG_CREATE?=	PKG_DBDIR=${PKG_DBDIR} ${PKG_TOOLS_BIN}/pkg_create
PKG_DELETE?=	PKG_DBDIR=${PKG_DBDIR} ${PKG_TOOLS_BIN}/pkg_delete
PKG_INFO?=	PKG_DBDIR=${PKG_DBDIR} ${PKG_TOOLS_BIN}/pkg_info
.else
PKG_ADD?=	${PKG_TOOLS_BIN}/pkg_add
PKG_ADMIN?=	${PKG_TOOLS_BIN}/pkg_admin
PKG_CREATE?=	${PKG_TOOLS_BIN}/pkg_create
PKG_DELETE?=	${PKG_TOOLS_BIN}/pkg_delete
PKG_INFO?=	${PKG_TOOLS_BIN}/pkg_info
.endif

.if !defined(PKGTOOLS_VERSION)
.if !exists(${IDENT})
PKGTOOLS_VERSION=${PKGTOOLS_REQD}
.else
PKGTOOLS_VERSION!=${IDENT} ${PKG_CREATE} ${PKG_DELETE} ${PKG_INFO} ${PKG_ADD} | ${AWK} 'BEGIN {n = 0;}; $$1 ~ /\$$NetBSD/ && $$2 !~ /^crt0/ {gsub("/", "", $$4); if ($$4 > n) {n = $$4;}}; END {print n;}'
.endif
.endif
MAKEFLAGS+=	PKGTOOLS_VERSION="${PKGTOOLS_VERSION}"

# Latest version of pkgtools required for this file.
PKGTOOLS_REQD=		20000202

# Check that we're using up-to-date pkg_* tools with this file.
uptodate-pkgtools:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ${PKGTOOLS_VERSION} -lt ${PKGTOOLS_REQD} ]; then		\
		case ${PKGNAME} in					\
		pkg_install-*)						\
			;;						\
		*)							\
			${ECHO} "Your package tools need to be updated to ${PKGTOOLS_REQD:C|(....)(..)(..)|\1/\2/\3|} versions."; \
			${ECHO} "The installed package tools were last updated on ${PKGTOOLS_VERSION:C|(....)(..)(..)|\1/\2/\3|}."; \
			${ECHO} "Please make and install the pkgsrc/pkgtools/pkg_install package."; \
			${FALSE} ;;					\
		esac							\
	fi

# Files to create for versioning and build information
BUILD_VERSION_FILE=	${WRKDIR}/.build_version
BUILD_INFO_FILE=	${WRKDIR}/.build_info

# Files containing size of pkg w/o and w/ all required pkgs
SIZE_PKG_FILE=		${WRKDIR}/.SizePkg
SIZE_ALL_FILE=		${WRKDIR}/.SizeAll

.ifndef PKG_ARGS
PKG_ARGS=		-v -c ${COMMENT} -d ${DESCR} -f ${PLIST} -l
PKG_ARGS+=		-b ${BUILD_VERSION_FILE} -B ${BUILD_INFO_FILE}
PKG_ARGS+=		-s ${SIZE_PKG_FILE} -S ${SIZE_ALL_FILE}
PKG_ARGS+=		-p ${PREFIX} -P "`${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_DEPENDS_QUICK=true|sort -u`"
.ifdef CONFLICTS
PKG_ARGS+=		-C "${CONFLICTS}"
.endif
.ifdef INSTALL_FILE
PKG_ARGS+=		-i ${INSTALL_FILE}
.endif
.ifdef DEINSTALL_FILE
PKG_ARGS+=		-k ${DEINSTALL_FILE}
.endif
.ifdef REQ_FILE
PKG_ARGS+=		-r ${REQ_FILE}
.endif
.ifdef MESSAGE_FILE
PKG_ARGS+=		-D ${MESSAGE_FILE}
.endif
.ifndef NO_MTREE
PKG_ARGS+=		-m ${MTREE_FILE}
.endif
.endif # !PKG_ARGS
PKG_SUFX?=		.tgz
# where pkg_add records its dirty deeds.
PKG_DBDIR?=		${DESTDIR}/var/db/pkg

# shared/dynamic motif libs
.if defined(USE_MOTIF)
MOTIFLIB?=	-L${MOTIFBASE}/lib -L${X11BASE}/lib -L${LOCALBASE}/lib -Wl,-R${MOTIFBASE}/lib -Wl,-R${X11BASE}/lib -Wl,-R${LOCALBASE}/lib -lXm
.endif

# Define SMART_MESSAGES in /etc/mk.conf for messages giving the tree
# of depencies for building, and the current target.
.ifdef SMART_MESSAGES
_PKGSRC_IN?=		===> ${.TARGET} [${PKGNAME}${_PKGSRC_DEPS}] ===
.else
_PKGSRC_IN?=		===
.endif

# Used to print all the '===>' style prompts - override this to turn them off.
ECHO_MSG?=		${ECHO}

# How to do nothing.  Override if you, for some strange reason, would rather
# do something.
DO_NADA?=		${TRUE}

ALL_TARGET?=		all
INSTALL_TARGET?=	install

.if defined(USE_IMAKE) && !defined(NO_INSTALL_MANPAGES)
INSTALL_TARGET+=	install.man
.endif

# If this host is behind a filtering firewall, use passive ftp(1)
.if defined(PASSIVE_FETCH)
FETCH_BEFORE_ARGS += -p
.endif

# Check if we got a real Motif, LessTif or no Motif at all.
.if defined(USE_MOTIF)
.if defined(USE_MOTIF12)
LESSTIF_DEPENDS=	lesstif12-*:../../x11/lesstif12
.else
LESSTIF_DEPENDS=	lesstif-*:../../x11/lesstif
.endif
.if exists(${MOTIFBASE}/include/Xm/Xm.h)
.if !defined(IS_LESSTIF)
IS_LESSTIF!=	${EGREP} -c LESSTIF ${MOTIFBASE}/include/Xm/Xm.h || ${TRUE}
MAKEFLAGS+=	IS_LESSTIF=${IS_LESSTIF}
.endif	# !IS_LESSTIF
.if (${IS_LESSTIF} != "0") || \
	(defined(USE_MOTIF12) && exists(${MOTIFBASE}/include/Xm/Gadget.h))
DEPENDS+=		${LESSTIF_DEPENDS}
.endif
.else
DEPENDS+=		${LESSTIF_DEPENDS}
.endif
.endif

# Check if we got Xpm distributed with XFree86 4.0 or newer or if we
# need to use the package.
.if defined(USE_XPM)
.if exists(${X11BASE}/include/X11/xpm.h)
__BUILTIN_XPM!=		${EGREP} -c NormalLibXpm ${X11BASE}/lib/X11/config/X11.tmpl  || ${TRUE}
.if (${__BUILTIN_XPM} == "0")
DEPENDS+=		xpm-3.4k:../../graphics/xpm
.endif
.undef __BUILTIN_XPM
.else
DEPENDS+=		xpm-3.4k:../../graphics/xpm
.endif
.endif

# Popular master sites
MASTER_SITE_XCONTRIB+=	\
	ftp://crl.dec.com/pub/X11/contrib/ \
	ftp://ftp.uni-paderborn.de/pub/X11/contrib/ \
	ftp://ftp.x.org/contrib/

MASTER_SITE_GNU+=	\
	ftp://ftp.gnu.org/pub/gnu/ \
	ftp://ftp.cs.columbia.edu/archives/gnu/prep/ \
	ftp://ftp.gwdg.de/pub/gnu/ \
	ftp://ftp.progsoc.uts.edu.au/pub/gnu/

MASTER_SITE_PERL_CPAN+=	\
	ftp://ftp.digital.com/pub/plan/perl/CPAN/modules/by-module/ \
	ftp://ftp.freesoftware.com/pub/perl/CPAN/modules/by-module/

MASTER_SITE_R_CRAN+=	\
	http://cran.r-project.org/src/ \
	ftp://cran.r-project.org/pub/R/src/ \
	http://cran.at.r-project.org/src/ \
	ftp://cran.at.r-project.org/pub/R/src/ \
	http://cran.dk.r-project.org/src/ \
	http://cran.ch.r-project.org/src/ \
	http://cran.uk.r-project.org/src/ \
	http://cran.us.r-project.org/src/ \
	http://lib.stat.cmu.edu/R/CRAN/src/ \
	ftp://ftp.biostat.washington.edu/mirrors/R/CRAN/src/ \
	http://cran.stat.wisc.edu/src/ \
	http://SunSITE.auc.dk/R/src/ \
	http://www.stat.unipg.it/pub/stat/statlib/R/CRAN/src/ \
	ftp://ftp.u-aizu.ac.jp/pub/lang/R/CRAN/src/ \
	ftp://dola.snu.ac.kr/pub/R/CRAN/src/ \
	http://stat.ethz.ch/CRAN/src/ \
	http://www.stats.bris.ac.uk/R/src/

MASTER_SITE_TEX_CTAN+=  \
	ftp://ftp.cdrom.com/pub/tex/ctan/  \
	ftp://ftp.wustl.edu/packages/TeX/  \
	ftp://ftp.funet.fi/pub/TeX/CTAN/  \
	ftp://ftp.tex.ac.uk/public/ctan/tex-archive/  \
	ftp://ftp.dante.de/tex-archive/

MASTER_SITE_SUNSITE+=	\
	ftp://sunsite.unc.edu/pub/Linux/ \
	ftp://ftp.infomagic.com/pub/mirrors/linux/sunsite/ \
	ftp://ftp.informatik.rwth-aachen.de/pub/comp/Linux/sunsite.unc.edu/

MASTER_SITE_GNOME+=	\
	ftp://ftp.gnome.org/pub/GNOME/ \
	ftp://ftp.sunet.se/pub/X11/GNOME/ \
	ftp://ftp.archive.de.uu.net/pub/X11/GNOME/ \
	ftp://ftp.tuwien.ac.at/hci/gnome.org/GNOME/

# Empty declaration to avoid "variable MASTER_SITES recursive" error
MASTER_SITES?=
PATCH_SITES?=

# The primary backup site.
MASTER_SITE_BACKUP?=	\
	ftp://ftp.netbsd.org/pub/NetBSD/packages/distfiles/ \
	ftp://ftp.freebsd.org/pub/FreeBSD/distfiles/
.if defined(DIST_SUBDIR)
_MASTER_SITE_BACKUP:=	${MASTER_SITE_BACKUP:=${DIST_SUBDIR}/}
.  if defined(MASTER_SITE_OVERRIDE)
_MASTER_SITE_OVERRIDE:=	${MASTER_SITE_OVERRIDE:=${DIST_SUBDIR}/}
.  endif # MASTER_SITE_OVERRIDE
.else  # !DIST_SUBDIR
_MASTER_SITE_BACKUP:=	${MASTER_SITE_BACKUP}
.  if defined(MASTER_SITE_OVERRIDE)
_MASTER_SITE_OVERRIDE:= ${MASTER_SITE_OVERRIDE}
.  endif # MASTER_SITE_OVERRIDE
.endif # DIST_SUBDIR

# Where to put distfiles that don't have any other master site
MASTER_SITE_LOCAL?= \
	${MASTER_SITE_BACKUP:=LOCAL_PORTS/}

# I guess we're in the master distribution business! :)  As we gain mirror
# sites for distfiles, add them to this list.
.if !defined(MASTER_SITE_OVERRIDE)
MASTER_SITES+=	${_MASTER_SITE_BACKUP}
PATCH_SITES+=	${_MASTER_SITE_BACKUP}
.else
MASTER_SITES:=	${_MASTER_SITE_OVERRIDE} ${MASTER_SITES}
PATCH_SITES:=	${_MASTER_SITE_OVERRIDE} ${PATCH_SITES}
.endif
  
# Derived names so that they're easily overridable.
DISTFILES?=		${DISTNAME}${EXTRACT_SUFX}
PKGNAME?=		${DISTNAME}

MAINTAINER?=		packages@netbsd.org

ALLFILES?=	${DISTFILES} ${PATCHFILES}
CKSUMFILES?=	${ALLFILES}
.for __tmp__ in ${IGNOREFILES}
CKSUMFILES:=	${CKSUMFILES:N${__tmp__}}
.endfor

# List of all files, with ${DIST_SUBDIR} in front.  Used for fetch and checksum.
.if defined(DIST_SUBDIR)
_CKSUMFILES?=	${CKSUMFILES:S/^/${DIST_SUBDIR}\//}
_DISTFILES?=	${DISTFILES:S/^/${DIST_SUBDIR}\//}
_IGNOREFILES?=	${IGNOREFILES:S/^/${DIST_SUBDIR}\//}
_PATCHFILES?=	${PATCHFILES:S/^/${DIST_SUBDIR}\//}
.else
_CKSUMFILES?=	${CKSUMFILES}
_DISTFILES?=	${DISTFILES}
_IGNOREFILES?=	${IGNOREFILES}
_PATCHFILES?=	${PATCHFILES}
.endif

# This is what is actually going to be extracted, and is overridable
#  by user.
EXTRACT_ONLY?=	${DISTFILES}

.if !defined(CATEGORIES) || !defined(DISTNAME)
.BEGIN:
	@${ECHO_MSG} "CATEGORIES and DISTNAME are mandatory."
	@${FALSE}
.endif

.if defined(LIB_DEPENDS)
.BEGIN:
	@${ECHO_MSG} "LIB_DEPENDS is deprecated and must be replaced with DEPENDS."
	@${FALSE}
.endif

.if defined(MASTER_SITE_SUBDIR)
.BEGIN:
	@${ECHO_MSG} 'MASTER_SITE_SUBDIR is deprecated and must be replaced with MASTER_SITES.'
	@${FALSE}
.endif

.if defined(PATCH_SITE_SUBDIR)
.BEGIN:
	@${ECHO_MSG} 'PATCH_SITE_SUBDIR is deprecated and must be replaced with PATCH_SITES.'
	@${FALSE}
.endif

.if defined(ONLY_FOR_ARCHS) || defined(NOT_FOR_ARCHS) \
	|| defined(ONLY_FOR_OPSYS) || defined(NOT_FOR_OPSYS)
.BEGIN:
	@${ECHO_MSG} 'ONLY/NOT_FOR_ARCHS/OPSYS are deprecated and must be replaced with ONLY/NOT_FOR_PLATFORM.'
	@${FALSE}
.endif

PKGREPOSITORYSUBDIR?=	All
PKGREPOSITORY?=		${PACKAGES}/${PKGREPOSITORYSUBDIR}
PKGFILE?=		${PKGREPOSITORY}/${PKGNAME}${PKG_SUFX}

CONFIGURE_SCRIPT?=	./configure
CONFIGURE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin

.if defined(GNU_CONFIGURE)
CONFIGURE_ARGS+=	--host=${MACHINE_GNU_PLATFORM} --prefix=${PREFIX}
HAS_CONFIGURE=		yes
.if ${X11PREFIX} == ${LOCALBASE}
CONFIGURE_ARGS+=        --x-libraries=${X11BASE}/lib --x-includes=${X11BASE}/include
.endif
.endif

# Passed to most of script invocations
SCRIPTS_ENV+= CURDIR=${.CURDIR} DISTDIR=${DISTDIR} \
	PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin \
	WRKDIR=${WRKDIR} WRKSRC=${WRKSRC} PATCHDIR=${PATCHDIR} \
	SCRIPTDIR=${SCRIPTDIR} FILESDIR=${FILESDIR} \
	PKGSRCDIR=${PKGSRCDIR} DEPENDS="${DEPENDS}" \
	PREFIX=${PREFIX} LOCALBASE=${LOCALBASE} X11BASE=${X11BASE}

.if defined(BATCH)
SCRIPTS_ENV+=	BATCH=yes
.endif

.MAIN: all

# Use aliases, so that all versions of English are acceptable
.if defined(LICENCE) && !defined(LICENSE)
LICENSE=	${LICENCE}
.endif

.if defined(ACCEPTABLE_LICENCES) && !defined(ACCEPTABLE_LICENSES)
ACCEPTABLE_LICENSES=	${ACCEPTABLE_LICENCES}
.endif

################################################################
# Many ways to disable a package.
#
# If we're in BATCH mode and the package is interactive, or we're
# in interactive mode and the package is non-interactive, skip all
# the important targets.  The reason we have two modes is that
# one might want to leave a build in BATCH mode running
# overnight, then come back in the morning and do _only_ the
# interactive ones that required your intervention.
#
# Don't attempt to build packages that require Motif if you don't
# have Motif.
#
# Ignore packages that can't be resold if building for a CDROM.
#
# Don't build a package if it's restricted and we don't want to get
# into that.
#
# Don't build a package if it's broken.
################################################################

.if !defined(NO_IGNORE)
.if (defined(IS_INTERACTIVE) && defined(BATCH))
IGNORE+= "${PKGNAME} is an interactive package"
.endif
.if (!defined(IS_INTERACTIVE) && defined(INTERACTIVE))
IGNORE+= "${PKGNAME} is not an interactive package"
.endif
.if (defined(NO_BIN_ON_CDROM) && defined(FOR_CDROM))
IGNORE+= "${PKGNAME} may not be placed in binary form on a CDROM:" \
         "    "${NO_BIN_ON_CDROM:Q}
.endif
.if (defined(NO_SRC_ON_CDROM) && defined(FOR_CDROM))
IGNORE+= "${PKGNAME} may not be placed in source form on a CDROM:" \
         "    "${NO_SRC_ON_CDROM:Q}
.endif
.if (defined(RESTRICTED) && defined(NO_RESTRICTED))
IGNORE+= "${PKGNAME} is restricted:" \
	 "    "${RESTRICTED:Q}
.endif
.if ((defined(USE_IMAKE) || defined(USE_MOTIF) || \
	defined(USE_X11BASE) || defined(USE_X11)) && \
       !exists(${X11BASE}))
IGNORE+= "${PKGNAME} uses X11, but ${X11BASE} not found"
.endif
.if defined(BROKEN)
IGNORE+= "${PKGNAME} is marked as broken:" ${BROKEN:Q}
.endif

.if defined(LICENSE)
.  ifdef ACCEPTABLE_LICENSES
.    for _lic in ${ACCEPTABLE_LICENSES}
.      if ${LICENSE} == "${_lic}"
_ACCEPTABLE=	yes
.      endif	# LICENSE == _lic
.    endfor	# _lic
.  endif	# ACCEPTABLE_LICENSES
.  ifndef _ACCEPTABLE
IGNORE+= "${PKGNAME} has unacceptable license: ${LICENSE}." \
	 "    To build this package, add this line to your /etc/mk.conf:" \
	 "    ACCEPTABLE_LICENSES+=${LICENSE}"
.  endif	# _ACCEPTABLE
.endif	# LICENSE

# Define __PLATFORM_OK only if the OS matches the pkg's allowed list.
.if defined(ONLY_FOR_PLATFORM) && !empty(ONLY_FOR_PLATFORM)
.  for __tmp__ in ${ONLY_FOR_PLATFORM}
.    if ${MACHINE_PLATFORM:M${__tmp__}} != ""
__PLATFORM_OK?=	yes
.    endif	# MACHINE_PLATFORM
.  endfor	# __tmp__
.else	# !ONLY_FOR_PLATFORM
__PLATFORM_OK?=	yes
.endif	# ONLY_FOR_PLATFORM
.for __tmp__ in ${NOT_FOR_PLATFORM}
.  if ${MACHINE_PLATFORM:M${__tmp__}} != ""
.    undef __PLATFORM_OK
.  endif	# MACHINE_PLATFORM
.endfor	# __tmp__
.if !defined(__PLATFORM_OK)
IGNORE+= "${PKGNAME} is not available for ${MACHINE_PLATFORM}"
.endif	# !__PLATFORM_OK

#
# Now print some error messages that we know we should ignore the pkg
#
.if defined(IGNORE)
fetch checksum extract patch configure all build install deinstall package \
install-depends check-depends:
.if defined(IGNORE_SILENT)
	@${DO_NADA}
.else
	@for str in ${IGNORE} ; \
	do \
		${ECHO} "${_PKGSRC_IN}> $$str" ; \
	done
.endif
.if defined(IGNORE_FAIL)
	${FALSE}
.endif
.endif # IGNORE
.endif # !NO_IGNORE

# Add these defs to the ones dumped into +BUILD_DEFS
BUILD_DEFS+=	OPSYS OS_VERSION MACHINE_ARCH MACHINE_GNU_ARCH
BUILD_DEFS+=	CPPFLAGS CFLAGS LDFLAGS
BUILD_DEFS+=	CONFIGURE_ENV CONFIGURE_ARGS
BUILD_DEFS+=	OBJECT_FMT LICENSE RESTRICTED
BUILD_DEFS+=	NO_SRC_ON_FTP NO_SRC_ON_CDROM
BUILD_DEFS+=	NO_BIN_ON_FTP NO_BIN_ON_CDROM

.if !target(all)
all: build
.endif

.if !defined(DEPENDS_TARGET)
.if make(package)
DEPENDS_TARGET=	package
.elif make(update)
DEPENDS_TARGET=	install
.else
DEPENDS_TARGET=	reinstall
.endif
.endif

################################################################
# The following are used to create easy dummy targets for
# disabling some bit of default target behavior you don't want.
# They still check to see if the target exists, and if so don't
# do anything, since you might want to set this globally for a
# group of packages in a Makefile.inc, but still be able to
# override from an individual Makefile.
################################################################

# Disable checksum
.if (defined(NO_CHECKSUM) && !target(checksum)) || exists(${EXTRACT_COOKIE})
checksum: fetch
	@${DO_NADA}
.endif

# Disable extract
.if defined(NO_EXTRACT) && !target(extract)
extract: checksum
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${EXTRACT_COOKIE}
checksum: fetch
	@${DO_NADA}
makesum:
	@${DO_NADA}
.endif

# Disable patch
.if defined(NO_PATCH) && !target(patch)
patch: extract
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${PATCH_COOKIE}
.endif

# Disable configure
.if defined(NO_CONFIGURE) && !target(configure)
configure: patch
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${CONFIGURE_COOKIE}
.endif

# Disable build
.if defined(NO_BUILD) && !target(build)
build: configure
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${BUILD_COOKIE}
.endif

# Disable install
.if defined(NO_INSTALL) && !target(install)
install: build
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${INSTALL_COOKIE}
.endif

# Disable package
.if defined(NO_PACKAGE) && !target(package)
package:
.if defined(IGNORE_SILENT)
	@${DO_NADA}
.else
	@${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} may not be packaged: ${NO_PACKAGE}."
.endif
.endif

# Disable describe
.if defined(NO_DESCRIBE) && !target(describe)
describe:
	@${DO_NADA}
.endif

################################################################
# More standard targets start here.
#
# These are the body of the build/install framework.  If you are
# not happy with the default actions, and you can't solve it by
# adding pre-* or post-* targets/scripts, override these.
################################################################

# Fetch
_FETCH_FILE=								\
	if [ ! -f $$file -a ! -f $$bfile -a ! -h $$bfile ]; then	\
		${ECHO_MSG} "=> $$bfile doesn't seem to exist on this system."; \
		if [ ! -w ${_DISTDIR}/. ]; then 			\
			${ECHO_MSG} "=> Can't download to ${_DISTDIR} (permission denied?)."; \
			exit 1; 					\
		fi; 							\
		for site in $$sites; do					\
			${ECHO_MSG} "=> Attempting to fetch $$bfile from $${site}."; \
			if ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${bfile} ${FETCH_AFTER_ARGS}; then \
				if [ -n "${FAILOVER_FETCH}" -a -f ${MD5_FILE} -a -f ${_DISTDIR}/$$bfile ]; then	\
					CKSUM=`${MD5} < ${_DISTDIR}/$$bfile`; \
					CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
					if [ "$$CKSUM" = "$$CKSUM2" -o "$$CKSUM2" = "IGNORE" ]; then \
						continue 2;		\
					else				\
						${ECHO_MSG} "=> Checksum failure - trying next site."; \
					fi;				\
				elif [ ! -f ${_DISTDIR}/$$bfile ]; then \
					${ECHO_MSG} "=> FTP didn't fetch expected file, trying next site." ; \
				else					\
					continue 2;			\
				fi;					\
			fi						\
		done;							\
		${ECHO_MSG} "=> Couldn't fetch $$bfile - please try to retrieve this";\
		${ECHO_MSG} "=> file manually into ${_DISTDIR} and try again."; \
		exit 1;							\
	fi

_CHECK_DIST_PATH=							\
	if [ "X${DIST_PATH}" != "X" ]; then				\
		for d in "" ${DIST_PATH:S/:/ /g}; do	\
			if [ "X$$d" = "X" -o "X$$d" = "X${DISTDIR}" ]; then continue; fi; \
			if [ -f $$d/${DIST_SUBDIR}/$$bfile ]; then	\
				${ECHO} "Using $$d/${DIST_SUBDIR}/$$bfile"; \
				${RM} -f $$bfile;			\
				${LN} -s $$d/${DIST_SUBDIR}/$$bfile $$bfile; \
				break;					\
			fi;						\
		done;							\
	fi

#
# Sort the master site list according to the patterns in MASTER_SORT
#
MASTER_SORT?=
MASTER_SORT_REGEX?=
MASTER_SORT_REGEX+= ${MASTER_SORT:S/./\\./g:C/.*/:\/\/[^\/]*&\//}

MASTER_SORT_AWK= BEGIN { RS = " "; ORS = " "; IGNORECASE = 1 ; gl = "${MASTER_SORT_REGEX}"; }
.for srt in ${MASTER_SORT_REGEX}
MASTER_SORT_AWK+= /${srt:C/\//\\\//g}/ { good["${srt}"] = good["${srt}"] " " $$0 ; next; } 
.endfor
MASTER_SORT_AWK+= { rest = rest " " $$0; } END { n=split(gl, gla); for(i=1;i<=n;i++) { print good[gla[i]]; } print rest; }
SORTED_MASTER_SITES_CMD= echo '${MASTER_SITES}' | ${AWK} '${MASTER_SORT_AWK}'


.if !target(do-fetch)
do-fetch:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_DISTDIR}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${_DISTDIR};			\
	 sites=`${SORTED_MASTER_SITES_CMD}`;				\
	 for file in "" ${_DISTFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		bfile=`${BASENAME} $$file`;				\
		${_CHECK_DIST_PATH};					\
		${_FETCH_FILE}						\
	 done
.if defined(_PATCHFILES)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${_DISTDIR};			\
	 sites="${PATCH_SITES}";					\
	 for file in "" ${_PATCHFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		bfile=`${BASENAME} $$file`;				\
		${_CHECK_DIST_PATH};					\
		${_FETCH_FILE}						\
	 done
.endif
.endif

.if !target(show-distfiles)
show-distfiles:
.if defined(IGNORE)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for file in "" ${_CKSUMFILES}; do				\
		if [ "X$$file" = "X" ]; then continue; fi;		\
		${ECHO} $$file;						\
	done
.endif
.endif

.if !target(show-downlevel)
show-downlevel:
.if defined(IGNORE)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${PKGBASE}<${PKGVERSION}\" || ${TRUE}`";\
	if [ "X$$found" != "X" -a "X$$found" != "X${PKGNAME}" ]; then	\
		${ECHO} "${PKGBASE} package: $$found installed, pkgsrc version ${PKGNAME}"; \
	fi
.endif
.endif

.if defined(EVAL_PREFIX)
.for def in ${EVAL_PREFIX}
.if !defined(${def:C/=.*//})
_dir_${def:C/=.*//} != (${PKG_INFO} -qp ${def:C/.*=//} 2>/dev/null; ${ECHO} " @cwd ${X11PREFIX}") | ${AWK} '{ print $$2; exit }'
${def:C/=.*//}=${_dir_${def:C/=.*//}}
MAKEFLAGS+= ${def:C/=.*//}=${_dir_${def:C/=.*//}}
.endif
.endfor
.endif

.if !target(show-pkgsrc-dir)
show-pkgsrc-dir:
.if defined(IGNORE)
	${_PKG_SILENT}${_PKG_DEBUG}${DO_NADA}
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${PKGWILDCARD}\" || ${TRUE}`";		\
	if [ "X$$found" != "X" ]; then					\
		${ECHO} ${PKGPATH};					\
	fi
.endif
.endif


# Extract

DOWNLOADED_DISTFILE=	${_DISTDIR}/$$file

.if !target(do-extract)
do-extract:
.ifndef NO_WRKDIR
.ifndef KEEP_WRKDIR
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${WRKDIR}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${WRKDIR}
.ifdef WRKOBJDIR
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR_BASENAME} || ${TRUE};				\
	if ${LN} -s ${WRKDIR} ${WRKDIR_BASENAME} 2>/dev/null; then	\
		${ECHO} "${WRKDIR_BASENAME} -> ${WRKDIR}";		\
	fi
.endif # WRKOBJDIR
.endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for file in "" ${EXTRACT_ONLY}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		(cd ${WRKDIR} && ${EXTRACT_CMD});			\
	done
.endif

# Patch

.if !target(do-patch)
do-patch:
.if defined(PATCHFILES)
	@${ECHO_MSG} "${_PKGSRC_IN}> Applying distribution patches for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}cd ${_DISTDIR}; \
	  for i in ${PATCHFILES}; do \
		if [ ${PATCH_DEBUG_TMP} = yes ]; then \
			${ECHO_MSG} "${_PKGSRC_IN}> Applying distribution patch $$i" ; \
		fi; \
		case $$i in \
			*.Z|*.gz) \
				${GZCAT} $$i | ${PATCH} ${PATCH_DIST_ARGS} \
				|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
				;; \
			*.bz2) \
				${BZCAT} $$i | ${PATCH} ${PATCH_DIST_ARGS} \
				|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
				;; \
			*) \
				${PATCH} ${PATCH_DIST_ARGS} < $$i \
				|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
				;; \
		esac; \
	  done
.endif
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${PATCHDIR} ]; then		\
		if [ "`${ECHO} ${PATCHDIR}/patch-*`" = "${PATCHDIR}/patch-*" ]; then \
			${ECHO_MSG} "${_PKGSRC_IN}> Ignoring empty patch directory"; \
			if [ -d ${PATCHDIR}/CVS ]; then			\
				${ECHO_MSG} "${_PKGSRC_IN}> Perhaps you forgot the -P flag to cvs co or update?"; \
			fi;						\
		else							\
			${ECHO_MSG} "${_PKGSRC_IN}> Applying ${OPSYS} patches for ${PKGNAME}" ; \
			fail="";					\
			for i in ${PATCHDIR}/patch-*; do		\
				case $$i in				\
				*.orig|*.rej|*~)			\
					${ECHO_MSG} "${_PKGSRC_IN}> Ignoring patchfile $$i" ; \
					continue;			\
					;;				\
				${PATCHDIR}/patch-local-*) 		\
					;;				\
				*)					\
					if [ -f ${PATCH_SUM_FILE} ]; then \
						filename=`expr $$i : '.*/\(.*\)'`; \
						calcsum=`${SED} -e '/\$$NetBSD.*/d' $$i | ${MD5}`; \
						recorded=`${AWK} '$$1 == "MD5" && $$2 == "('$$filename')" { print $$4; }' ${PATCH_SUM_FILE} || ${TRUE}`; \
						if [ "X$$recorded" = "X" ]; then \
							${ECHO_MSG} "**************************************"; \
							${ECHO_MSG} "Ignoring unknown patch file: $$i"; \
							${ECHO_MSG} "**************************************"; \
							continue;	\
						fi;			\
						if [ "X$$calcsum" != "X$$recorded" ]; then \
							${ECHO_MSG} "**************************************"; \
							${ECHO_MSG} "Patch file $$i has been modified"; \
							${ECHO_MSG} "**************************************"; \
							fail="$$fail $$filename"; \
							continue;	\
						fi;			\
					fi;				\
					;;				\
				esac;					\
				if [ ${PATCH_DEBUG_TMP} = yes ]; then	\
					${ECHO_MSG} "${_PKGSRC_IN}> Applying ${OPSYS} patch $$i" ; \
				fi;					\
				fuzz="";				\
				${PATCH} -v > /dev/null 2>&1 && fuzz="${PATCH_FUZZ_FACTOR}"; \
				${PATCH} $$fuzz ${PATCH_ARGS} < $$i ||	\
					( ${ECHO} Patch $$i failed ; exit 1 ) ; \
			done;						\
			if [ "X$$fail" != "X" ]; then			\
				${ECHO_MSG} "Patching failed due to modified patch file(s): $$fail"; \
				exit 1;					\
			fi;						\
		fi;							\
	fi
.endif

# Configure

.if !target(do-configure)
do-configure:
.if defined(REPLACE_NCURSES) && (!defined(NEED_NCURSES) || ${NEED_NCURSES} == "NO")
.for f in ${REPLACE_NCURSES}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC}; if [ -f ${f} ]; then	\
		${SED}  -e "s/ncurses/curses/g" ${f} > ${f}.new;	\
		if [ -x ${f} ]; then					\
			${MV} ${f}.new ${f};				\
			${CHMOD} a+x ${f};				\
		else							\
			${MV} ${f}.new ${f};				\
		fi							\
	fi
.endfor
.endif

.if defined(USE_LIBTOOL) && defined(LTCONFIG_OVERRIDE) && !defined(LIBTOOL_OVERRIDE)
.for ltconfig in ${LTCONFIG_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}\
	if [ -f ${ltconfig} ]; then \
		${RM} -f ${ltconfig}; \
		${ECHO} "${RM} -f libtool; ${LN} -s ${LIBTOOL} libtool" \
			> ${ltconfig}; \
		${CHMOD} +x ${ltconfig} ; \
	fi
.endfor
.endif
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/configure ]; then \
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH} \
		  ${SCRIPTDIR}/configure; \
	fi
.if defined(HAS_CONFIGURE)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} CC="${CC}" ac_cv_path_CC="${CC}" \
	    CFLAGS="${CFLAGS}" \
	    INSTALL="`${TYPE} ${INSTALL} | ${AWK} '{ print $$NF }'` -c -o ${BINOWN} -g ${BINGRP}" \
	    ac_given_INSTALL="`${TYPE} ${INSTALL} | ${AWK} '{ print $$NF }'` -c -o ${BINOWN} -g ${BINGRP}" \
	    INSTALL_DATA="${INSTALL_DATA}" \
	    INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
	    INSTALL_SCRIPT="${INSTALL_SCRIPT}" \
	    ${CONFIGURE_ENV} ${CONFIGURE_SCRIPT} ${CONFIGURE_ARGS}
.endif
.if defined(USE_IMAKE)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${SCRIPTS_ENV} XPROJECTROOT=${X11BASE} ${XMKMF}
.endif
.if defined(USE_LIBTOOL) && defined(LIBTOOL_OVERRIDE) && !defined(LTCONFIG_OVERRIDE)
.for libtool in ${LIBTOOL_OVERRIDE}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${libtool} ]; then \
		${RM} -f ${libtool}; \
		${LN} -s ${LIBTOOL} ${libtool}; \
	fi
.endfor
.endif
.endif

# Build

.if !target(do-build)
do-build:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${ALL_TARGET}
.endif

# Install

.if !target(do-install)
do-install:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${INSTALL_TARGET}
.endif

# Package

.if !target(do-package)
do-package: ${PLIST} ${DESCR}
	${_PKG_SILENT}${_PKG_DEBUG}if ${TEST} -e ${PLIST}; then		\
		${ECHO_MSG} "${_PKGSRC_IN}> Building binary package for ${PKGNAME}"; \
		if [ ! -d ${PKGREPOSITORY} ]; then			\
			${MKDIR} ${PKGREPOSITORY};			\
			if [ $$? -ne 0 ]; then				\
				${ECHO_MSG} "=> Can't create directory ${PKGREPOSITORY}."; \
				exit 1;					\
			fi;						\
		fi;							\
		if ${PKG_CREATE} ${PKG_ARGS} ${PKGFILE}; then		\
			${MAKE} ${MAKEFLAGS} package-links;		\
		else							\
			${MAKE} ${MAKEFLAGS} delete-package;		\
			exit 1;						\
		fi;							\
	fi
.if defined(NO_BIN_ON_CDROM)
	@${ECHO_MSG} "${_PKGSRC_IN}> Warning: ${PKGNAME} may not be put on a CD-ROM:"
	@${ECHO_MSG} "${_PKGSRC_IN}>         " ${NO_BIN_ON_CDROM:Q}
.endif
.if defined(NO_BIN_ON_FTP)
	@${ECHO_MSG} "${_PKGSRC_IN}> Warning: ${PKGNAME} may not be made available through FTP:"
	@${ECHO_MSG} "${_PKGSRC_IN}>         " ${NO_BIN_ON_FTP:Q}
.endif
.endif

# Some support rules for do-package

.if !target(package-links)
package-links:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} delete-package-links
	${_PKG_SILENT}${_PKG_DEBUG}for cat in ${CATEGORIES}; do		\
		if [ ! -d ${PACKAGES}/$$cat ]; then			\
			${MKDIR} ${PACKAGES}/$$cat;			\
			if [ $$? -ne 0 ]; then				\
				${ECHO_MSG} "=> Can't create directory ${PACKAGES}/$$cat."; \
				exit 1;					\
			fi;						\
		fi;							\
		${RM} -f ${PACKAGES}/$$cat/${PKGNAME}${PKG_SUFX};	\
		${LN} -s ../${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX} ${PACKAGES}/$$cat; \
	done;
.endif

.if !target(delete-package-links)
delete-package-links:
	${_PKG_SILENT}${_PKG_DEBUG}\
	${FIND} ${PACKAGES} -type l -name ${PKGNAME}${PKG_SUFX} | xargs ${RM} -f
.endif

.if !target(delete-package)
delete-package:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} delete-package-links
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PKGFILE}
.endif

# Set the PLIST_SRC definition, if necessary
.if !defined(PLIST_SRC)
.if exists(${PKGDIR}/PLIST)
PLIST_SRC=	${PKGDIR}/PLIST
.elif exists(${PKGDIR}/PLIST-mi) && \
      exists(${PKGDIR}/PLIST-md.shared) && \
      exists(${PKGDIR}/PLIST-md.static)
PLIST_SRC=	${PKGDIR}/PLIST-mi
.if defined(NOPIC)
PLIST_SRC+=	${PKGDIR}/PLIST-md.static
.else
PLIST_SRC+=	${PKGDIR}/PLIST-md.shared
.endif  # NOPIC
.else   # no PLIST at all
PLIST_SRC=
.endif  # ${PKGDIR}/PLIST
.endif  # !PLIST_SRC

################################################################
# This is the "generic" package target, actually a macro used from the
# six main targets.  See below for more.
################################################################

_PORT_USE: .USE
.if make(real-extract)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} install-build-depends install-run-depends DEPENDS_TARGET=${DEPENDS_TARGET}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${MAKEFLAGS} ${.TARGET:S/^real-/pre-/}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/${.TARGET:S/^real-/pre-/} ]; then		\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/${.TARGET:S/^real-/pre-/};		\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${MAKEFLAGS} ${.TARGET:S/^real-/do-/}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${MAKEFLAGS} ${.TARGET:S/^real-/post-/}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/${.TARGET:S/^real-/post-/} ]; then	\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/${.TARGET:S/^real-/post-/};	\
	fi
.if !make(real-fetch)							\
	&& (!make(real-patch) || !defined(PATCH_CHECK_ONLY))		\
	&& (!make(real-package) || !defined(PACKAGE_NOINSTALL))
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${TOUCH} ${TOUCH_FLAGS} ${WRKDIR}/.${.TARGET:S/^real-//}_done
.endif

root-install:
.if !defined(NO_PKG_REGISTER) && !defined(FORCE_PKG_REGISTER)
.if defined(CONFLICTS)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR}/.CONFLICTS
.for conflict in ${CONFLICTS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${conflict}\" || ${TRUE}`";		\
	if [ X"$$found" != X"" ]; then					\
		${ECHO} "$$found" >> ${WRKDIR}/.CONFLICTS;		\
	fi
.endfor
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -s ${WRKDIR}/.CONFLICTS ]; then \
		found=`cat ${WRKDIR}/.CONFLICTS | ${SED} -e s'|${PKG_DBDIR}/||g' | tr '\012' ' '`; \
		${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} conflicts with installed package(s): $$found found."; \
		${ECHO_MSG} "*** They install the same files into the same place."; \
		${ECHO_MSG} "*** Please remove $$found first with pkg_delete(1)."; \
		${RM} -f ${WRKDIR}/.CONFLICTS;				\
		exit 1;							\
	fi
.endif	# CONFLICTS
	${_PKG_SILENT}${_PKG_DEBUG}					\
	found="`${PKG_INFO} -e \"${PKGWILDCARD}\" || ${TRUE}`";		\
	if [ "$$found" != "" ]; then					\
		${ECHO_MSG} "${_PKGSRC_IN}>  $$found is already installed - perhaps an older version?"; \
		${ECHO_MSG} "*** If so, you may wish to \`\`pkg_delete $$found'' and install"; \
		${ECHO_MSG} "*** this package again by \`\`${MAKE} reinstall'' to upgrade it properly,"; \
		${ECHO_MSG} "*** or use \`\`${MAKE} update'' to upgrade it and all of its dependencies."; \
		${ECHO_MSG} "*** If you really wish to overwrite the old package of $$found"; \
		${ECHO_MSG} "*** without deleting it first, set the variable \"FORCE_PKG_REGISTER\""; \
		${ECHO_MSG} "*** in your environment or the \"${MAKE} install\" command line."; \
		exit 1;							\
	fi
.endif # !NO_PKG_REGISTER && !NO_FORCE_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${SH} -c umask` != ${DEF_UMASK} ]; then \
		${ECHO_MSG} "${_PKGSRC_IN}>  Warning: your umask is \"`${SH} -c umask`"\".; \
		${ECHO_MSG} "If this is not desired, set it to an appropriate value (${DEF_UMASK})"; \
		${ECHO_MSG} "and install this package again by \`\`${MAKE} deinstall reinstall''."; \
	fi
.if !defined(NO_MTREE)
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${ID} -u` = 0 ]; then		\
		if [ ! -f ${MTREE_FILE} ]; then				\
			${ECHO_MSG} "Error: mtree file \"${MTREE_FILE}\" is missing."; \
			exit 1;						\
		else							\
			if [ ! -d ${PREFIX} ]; then			\
				mkdir -p ${PREFIX};			\
			fi;						\
			${MTREE} ${MTREE_ARGS} ${PREFIX}/;		\
		fi;							\
	else								\
		${ECHO_MSG} "Warning: not superuser, can't run mtree."; \
		${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
	fi
.endif # !NO_MTREE
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${MAKEFLAGS} pre-install
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/pre-install ]; then		\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/pre-install;		\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${MAKEFLAGS} do-install
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${MAKEFLAGS} post-install
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/post-install ]; then	\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/post-install;	\
	fi
.for f in ${INFO_FILES}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} "install-info --info-dir=${PREFIX}/info ${PREFIX}/info/${f}"; \
	install-info --remove --info-dir=${PREFIX}/info ${PREFIX}/info/${f}; \
	install-info --info-dir=${PREFIX}/info ${PREFIX}/info/${f}
.endfor
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} ${PLIST}
	${_PKG_SILENT}${_PKG_DEBUG}newmanpages=`${EGREP} -h		\
		'^([^@/]*/)*man/([^/]*/)?(man[1-9ln]/.*\.[1-9ln]|cat[1-9ln]/.*\.0)(\.gz)?$$' \
		${PLIST} 2>/dev/null || ${TRUE}`;			\
	if [ X"${MANCOMPRESSED}" != X"" -a X"${MANZ}" = X"" ]; then	\
		${ECHO_MSG} "${_PKGSRC_IN}> [Automatic manual page handling]";	\
		${ECHO_MSG} "${_PKGSRC_IN}> Decompressing manual pages for ${PKGNAME}";	\
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -h ${PREFIX}/$$manpage.gz ]; then		\
				set - `${FILE} ${PREFIX}/$$manpage.gz | ${SED} -e 's|\.gz$$||'`; \
				shift `expr $$# - 1`;			\
				${RM} -f ${PREFIX}/$$manpage;		\
				${LN} -s $${1} ${PREFIX}/$$manpage;	\
				${RM} ${PREFIX}/$$manpage.gz;		\
			else						\
				${GUNZIP_CMD} ${PREFIX}/$$manpage.gz;	\
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$manpage";		\
			fi;						\
		done;							\
	fi;								\
	if [ X"${MANCOMPRESSED}" = X"" -a X"${MANZ}" != X"" ]; then	\
		${ECHO_MSG} "${_PKGSRC_IN}> [Automatic manual page handling]";	\
		${ECHO_MSG} "${_PKGSRC_IN}> Compressing manual pages for ${PKGNAME}"; \
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -h ${PREFIX}/$$manpage ]; then		\
				set - `${FILE} ${PREFIX}/$$manpage`;	\
				shift `expr $$# - 1`;			\
				${RM} -f ${PREFIX}/$$manpage.gz; 	\
				${LN} -s $${1}.gz ${PREFIX}/$$manpage.gz; \
				${RM} ${PREFIX}/$$manpage;		\
			else						\
				${GZIP_CMD} ${PREFIX}/$$manpage;	\
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$manpage";		\
			fi;						\
		done;							\
	fi
.if ${OPSYS} == "NetBSD" || ${OPSYS} == "SunOS"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	sos=`${EGREP} -h -x '.*/lib[^/]+\.so\.[0-9]+(\.[0-9]+)+' ${PLIST} || ${TRUE}`; \
	if [ "X$$sos" != "X" ]; then					\
		shlib_type=`${MAKE} ${MAKEFLAGS} show-shlib-type`;	\
		case "$$shlib_type" in					\
		"ELF")							\
			${ECHO_MSG} "${_PKGSRC_IN}> [Automatic ELF shared object handling]";\
			${AWK} 'function makelinks(target, lib, v1, v2, v3) { \
					print target;			\
					slashc = split(target, slashes, "/"); \
					if (v3 >= 0) {			\
						system(sprintf("${RM} -f ${PREFIX}/%s.%s.%s.%s; ${LN} -s %s ${PREFIX}/%s.%s.%s.%s", lib, v1, v2, v3, slashes[slashc], lib, v1, v2, v3)); \
						printf("%s.%s.%s.%s\n", lib, v1, v2, v3); \
					}				\
					system(sprintf("${RM} -f ${PREFIX}/%s.%s.%s; ${LN} -s %s ${PREFIX}/%s.%s.%s", lib, v1, v2, slashes[slashc], lib, v1, v2)); \
					system(sprintf("${RM} -f ${PREFIX}/%s.%s; ${LN} -s %s ${PREFIX}/%s.%s", lib, v1, slashes[slashc], lib, v1)); \
					printf("%s.%s.%s\n%s.%s\n", lib, v1, v2, lib, v1); \
				}					\
				/^@/ { print; next }			\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+\.[0-9]+$$/ { \
					dotc = split($$0, dots, "\.");	\
					lib = dots[1];			\
					for (i = 2 ; i <= dotc - 4 ; i++) \
						lib = lib "." dots[i];	\
					makelinks($$0, lib, dots[dotc - 3], dots[dotc - 2], dots[dotc - 1]); \
					next;				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+\.[0-9]+$$/ {	\
					dotc = split($$0, dots, "\.");	\
					lib = dots[1];			\
					for (i = 2 ; i <= dotc - 3 ; i++) \
						lib = lib "." dots[i];	\
					makelinks($$0, lib, dots[dotc - 2], dots[dotc - 1], -1); \
					next;				\
				}					\
				/.*\/lib[^\/]+\.so\.[0-9]+$$/ { next; }	\
				/.*\/lib[^\/]+\.so$$/ { next; }		\
				{ print; }' < ${PLIST} > ${PLIST}.tmp && ${MV} ${PLIST}.tmp ${PLIST}; \
			;;						\
		"a.out")						\
			${ECHO_MSG} "${_PKGSRC_IN}> [Automatic a.out shared object handling]";\
			cnt=`${EGREP} -c -x '@exec[ 	]*${LDCONFIG}' ${PLIST} || ${TRUE}`; \
			if [ $$cnt -eq 0 ]; then			\
				${ECHO} "@exec ${LDCONFIG}" >> ${PLIST}; \
				${ECHO} "@unexec ${LDCONFIG}" >> ${PLIST}; \
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$sos";			\
				${ECHO_MSG} "Running ${LDCONFIG}";	\
			fi;						\
			${LDCONFIG} || ${TRUE};				\
			;;						\
		"*")							\
			${ECHO_MSG} "No shared libraries for ${MACHINE_ARCH}"; \
			for so in $$sos; do				\
				if [ X"${PKG_VERBOSE}" != X"" ]; then	\
					${ECHO_MSG} "Ignoring $$so";	\
				fi;					\
				${SED} -e "s;^$$so$$;@comment No shared objects - &;" ${PLIST} > ${PLIST}.tmp && \
					${MV} ${PLIST}.tmp ${PLIST};	\
			done;						\
			;;						\
		esac;							\
	fi
.endif
.ifdef MESSAGE_FILE
	@${ECHO_MSG} "${_PKGSRC_IN}> Please note the following:"
	@${ECHO_MSG} ""
	@${CAT} ${MESSAGE_FILE}
	@${ECHO_MSG} ""
.endif
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} fake-pkg
.endif # !NO_PKG_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${INSTALL_COOKIE}
.if defined(PKG_DEVELOPER)
	@${MAKE} ${MAKEFLAGS} check-shlibs
.endif


# Check if all binaries and shlibs find their needed libs
# Must be run after "make install", so that files are installed, and
# ${PLIST} exists.
#
check-shlibs:
	${_PKG_SILENT}${_PKG_DEBUG}\
	bins=`${PKG_INFO} -qL ${PKGNAME} | ( ${EGREP} -h '/(bin|sbin|libexec)/' || ${TRUE} )`; \
	if [ "${OBJECT_FMT}" = "ELF" ]; then \
		shlibs=`${PKG_INFO} -qL ${PKGNAME} | ( ${EGREP} -h '/lib/lib.*.so' || ${TRUE} )`; \
	else \
		shlibs=""; \
	fi ; \
	if [ X${LDD} = X ]; then \
		ldd=`${TYPE} ldd | ${AWK} '{ print $$NF }'` ; \
	else \
		ldd="${LDD}" ; \
	fi ; \
	for i in $${bins} $${shlibs} ; do \
		err=`( $$ldd $$i 2>&1 || ${TRUE} ) | ( ${GREP} "not found" || ${TRUE} )`; \
		if [ "${PKG_VERBOSE}" != "" ]; then \
			echo "$$ldd $$i" ; \
		fi ; \
		if [ "$$err" != "" ]; then \
			echo "$$i: $$err" ; \
			error=1; \
		fi ; \
	done ; \
	if [ "$$error" = 1 ]; then \
		${ECHO} "*** The above programs/libs will not find the listed shared libraries"; \
		${ECHO} "    at runtime. Please fix the package (add -Wl,-R.../lib in the right places)!" ; \
		${SHCOMMENT} Might not error-out for non-pkg-developers; \
		exit 1 ; \
	fi


.if !target(show-shlib-type)
# Show the shared lib type being built: one of ELF, a.out or none
show-shlib-type:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${WRKDIR} &&							\
	sotype=none;							\
	if [ "X${MKPIC}" != "Xno" -a "X${NOPIC}" = "X" ]; then		\
		${ECHO} "int main() { exit(0); }" > a.$$$$.c;		\
		${CC} ${CFLAGS} a.$$$$.c -o a.$$$$.out;			\
		case `${FILE} a.$$$$.out` in				\
		*ELF*dynamically*)					\
			sotype=ELF ;;					\
		*dynamically*)						\
			sotype="a.out" ;;				\
		esac;							\
	fi;								\
	${ECHO} "$$sotype";						\
	${RM} -f a.$$$$.c a.$$$$.out
.endif
 

################################################################
# Skeleton targets start here
# 
# You shouldn't have to change these.  Either add the pre-* or
# post-* targets/scripts or redefine the do-* targets.  These
# targets don't do anything other than checking for cookies and
# call the necessary targets/scripts.
################################################################

.if !target(fetch)
fetch:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-fetch
.endif

.if !target(extract)
extract: checksum ${EXTRACT_COOKIE}
.endif

.if !target(patch)
patch: extract ${PATCH_COOKIE}
.endif

.if !target(configure)
configure: patch ${CONFIGURE_COOKIE}
.endif

.if !target(build)
build: configure ${BUILD_COOKIE}
.endif

.if !target(install)
install: uptodate-pkgtools build ${INSTALL_COOKIE}
.endif

.if !target(package)
package: uptodate-pkgtools install ${PACKAGE_COOKIE}
.endif

${EXTRACT_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-extract DEPENDS_TARGET=${DEPENDS_TARGET}
${PATCH_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-patch
${CONFIGURE_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-configure
${BUILD_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-build
${INSTALL_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-install
${PACKAGE_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} real-package

# And call the macros

real-fetch: _PORT_USE
real-extract: _PORT_USE
	@${ECHO_MSG} "${_PKGSRC_IN}> Extracting for ${PKGNAME}"
real-patch: _PORT_USE
	@${ECHO_MSG} "${_PKGSRC_IN}> Patching for ${PKGNAME}"
real-configure: _PORT_USE
	@${ECHO_MSG} "${_PKGSRC_IN}> Configuring for ${PKGNAME}"
real-build: _PORT_USE
	@${ECHO_MSG} "${_PKGSRC_IN}> Building for ${PKGNAME}"
real-install: pkg-su-install
real-package: _PORT_USE

# sudo or priv are acceptable substitutes
SU_CMD?=	${SU} - root -c
PRE_ROOT_CMD?=	${TRUE}

pkg-su-install:
	@${ECHO_MSG} "${_PKGSRC_IN}> Installing for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ `${ID} -u` = 0 ]; then					\
		${MAKE} ${MAKEFLAGS} root-install;			\
	elif [ "X${BATCH}" != X"" ]; then				\
		${ECHO_MSG} "Warning: Batch mode, not superuser, can't run mtree."; \
		${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
	else								\
		make=`${TYPE} ${MAKE} | ${AWK} '{ print $$NF }'`;	\
		args="";						\
		if [ "X${FORCE_PKG_REGISTER}" != X"" ]; then		\
			args="FORCE_PKG_REGISTER=1";			\
		fi;							\
		if [ "X${PKG_DEBUG_LEVEL}" != X"" ]; then		\
			args="$$args PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL}"; \
		fi;							\
		if [ "X${PRE_ROOT_CMD}" != "X${TRUE}" ]; then		\
			${ECHO} "*** WARNING *** Running: ${PRE_ROOT_CMD}"; \
			${PRE_ROOT_CMD};				\
		fi;                                             	\
		${ECHO_MSG} "${_PKGSRC_IN}> Becoming root@`/bin/hostname` to install ${PKGNAME}."; \
		${ECHO_MSG} -n "`${ECHO} ${SU_CMD} | ${AWK} '{ print $$1 }'` ";\
		${SU_CMD} "cd ${.CURDIR}; $$make $$args ${MAKEFLAGS} root-install"; \
	fi

# Empty pre-* and post-* targets, note we can't use .if !target()
# in the _PORT_USE macro

.for name in fetch extract patch configure build install package

.if !target(pre-${name})
pre-${name}:
	@${DO_NADA}
.endif

.if !target(post-${name})
post-${name}:
	@${DO_NADA}
.endif

.endfor

# Checkpatch
#
# Special target to verify patches

.if !target(checkpatch)
checkpatch:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} PATCH_CHECK_ONLY=yes ${MAKEFLAGS} patch
.endif

# Reinstall
#
# Special target to re-run install

.if !target(reinstall)
reinstall:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE} ${PLIST}
	${_PKG_SILENT}${_PKG_DEBUG}DEPENDS_TARGET=${DEPENDS_TARGET} ${MAKE} ${MAKEFLAGS} install
.endif

# Deinstall
#
# Special target to remove installation

.if !target(deinstall)
deinstall: pkg-su-deinstall

pkg-su-deinstall: uptodate-pkgtools
	@${ECHO_MSG} "${_PKGSRC_IN}> Deinstalling for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ `${ID} -u` = 0 ]; then					\
		${MAKE} ${MAKEFLAGS} root-deinstall;			\
	else								\
		make=`${TYPE} ${MAKE} | ${AWK} '{ print $$NF }'`;	\
		${ECHO_MSG} "${_PKGSRC_IN}> Becoming root@`/bin/hostname` to deinstall ${PKGNAME}."; \
		${SU_CMD} "cd ${.CURDIR}; $$make ${MAKEFLAGS} PKG_DEBUG_LEVEL=${PKG_DEBUG_LEVEL} root-deinstall DEINSTALLDEPENDS=${DEINSTALLDEPENDS}"; \
	fi


.if (${DEINSTALLDEPENDS} != "NO")
.if (${DEINSTALLDEPENDS} != "ALL")
# used for removing stuff in bulk builds
root-deinstall-flags+=	-r -R
# used for "update" target
.else
root-deinstall-flags+=	-r
.endif
.endif
.ifdef PKG_VERBOSE
root-deinstall-flags+=	-v
.endif

root-deinstall:
	${_PKG_SILENT}${_PKG_DEBUG} \
	found="`${PKG_INFO} -e \"${PKGWILDCARD}\" || ${TRUE}`"; \
	if [ "$$found" != "" ]; then \
		${ECHO} Running ${PKG_DELETE} ${root-deinstall-flags} $$found ; \
		${PKG_DELETE} ${root-deinstall-flags} $$found || ${TRUE} ; \
	fi
.if (${DEINSTALLDEPENDS} != "NO") && (${DEINSTALLDEPENDS} != "ALL")
	@${SHCOMMENT} Also remove BUILD_DEPENDS:
.for pkg in ${BUILD_DEPENDS:C/:.*$//}
	${_PKG_SILENT}${_PKG_DEBUG} \
	found="`${PKG_INFO} -e \"${pkg}\" || ${TRUE}`"; \
	if [ "$$found" != "" ]; then \
		${ECHO} Running ${PKG_DELETE} $$found ; \
		${PKG_DELETE} ${root-deinstall-flags} $$found || ${TRUE} ; \
	fi
.endfor
.endif # DEINSTALLDEPENDS
	@${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE}
.endif						# target(deinstall)


################################################################
# Some more targets supplied for users' convenience
################################################################

# The 'update' target can be used to update a package and all
# currently installed packages that depend upon this package.

.if exists(${DDIR})
RESUMEUPDATE?=	YES
CLEAR_DIRLIST?=	NO

update:
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_MSG}				\
		"${_PKGSRC_IN}> Resuming update for ${PKGNAME}"
.if ${REINSTALL} != "NO"
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} deinstall DEINSTALLDEPENDS=ALL
.endif
.else
RESUMEUPDATE?=	NO
CLEAR_DIRLIST?=	YES

update:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} ${DDIR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} deinstall DEINSTALLDEPENDS=ALL
.endif
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} ${DEPENDS_TARGET} KEEP_WRKDIR=YES
	${_PKG_SILENT}${_PKG_DEBUG}					\
	[ ! -s ${DDIR} ] || for dep in `${CAT} ${DDIR}` ; do		\
		(if cd ../.. && cd "$${dep}" ; then				\
			${ECHO_MSG} "${_PKGSRC_IN}> Installing in $${dep}" &&	\
			if [ "${RESUMEUPDATE}" = "NO" -o 		\
			     "${REINSTALL}" != "NO" ] ; then		\
				${MAKE} ${MAKEFLAGS} deinstall;		\
			fi &&						\
			${MAKE} ${MAKEFLAGS} ${DEPENDS_TARGET};		\
		else							\
			${ECHO_MSG} "${_PKGSRC_IN}> Skipping removed directory $${dep}";\
		fi) ;							\
	done
.if ${NOCLEAN} == "NO"
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} clean-update CLEAR_DIRLIST=YES
.endif


clean-update:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} ${DDIR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -s ${DDIR} ] ; then					\
		for dep in `${CAT} ${DDIR}` ; do			\
			(if cd ../.. && cd "$${dep}" ; then			\
				${MAKE} ${MAKEFLAGS} clean ;		\
			else						\
				${ECHO_MSG} "${_PKGSRC_IN}> Skipping removed directory $${dep}";\
			fi) ;						\
		done ;							\
	fi
.if ${CLEAR_DIRLIST} != "NO"
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} clean
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
		${MAKE} ${MAKEFLAGS} clean update-dirlist		\
		DIRLIST="`${CAT} ${DDIR}`" PKGLIST="`${CAT} ${DLIST}`"
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO_MSG}				\
		"${_PKGSRC_IN}> Warning: preserved leftover directory list.  Your next";\
		${ECHO_MSG} "${_PKGSRC_IN}>          \`\`${MAKE} update'' may fail.  It is advised to use";\
		${ECHO_MSG} "${_PKGSRC_IN}>          \`\`${MAKE} update REINSTALL=YES'' instead!"
.endif


update-dirlist:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} -p ${WRKDIR}
.ifdef PKGLIST
.for __tmp__ in ${PKGLIST}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} >>${DLIST} "${__tmp__}"
.endfor
.endif
.ifdef DIRLIST
.for __tmp__ in ${DIRLIST}
	${_PKG_SILENT}${_PKG_DEBUG}${ECHO} >>${DDIR} "${__tmp__}"
.endfor
.endif


${DDIR}: ${DLIST}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	ddir=`${SED} 's:-[^-]*$$::' <${DLIST}`;				\
	${ECHO} >${DDIR};						\
	for pkg in $${ddir} ; do					\
		if ${PKG_INFO} -b $${pkg} >/dev/null 2>&1 ; then	\
			${PKG_INFO} -b $${pkg} | ${SED}	-ne		\
			    's,\([^/]*/[^/]*\)/Makefile:.*,\1,p' | 	\
			    ${HEAD} -1 >>${DDIR};			\
		fi ;							\
	done

${DLIST}:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} -p ${WRKDIR}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${PKG_INFO} -R "${PKGWILDCARD}" || ${TRUE}) |	\
		${TAIL} -n +4 >${DLIST}

# The 'info' target can be used to display information about a package.

info: uptodate-pkgtools
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_INFO} ${PKGWILDCARD}

# This is for the use of sites which store distfiles which others may
# fetch - only fetch the distfile if it is allowed to be
# re-distributed freely
mirror-distfiles:
.if !defined(NO_SRC_ON_FTP)
	@${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} fetch NO_IGNORE=yes NO_CHECK_DEPENDS=yes
.endif


# Cleaning up

.if !target(pre-clean)
pre-clean:
	@${DO_NADA}
.endif

.if !target(clean)
clean: pre-clean
.if (${CLEANDEPENDS} != "NO") && (defined(BUILD_DEPENDS) || defined(DEPENDS))
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${MAKEFLAGS} clean-depends
.endif
	@${ECHO_MSG} "${_PKGSRC_IN}> Cleaning for ${PKGNAME}"
.if !defined(NO_WRKDIR)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -d ${WRKDIR} ]; then					\
		if [ -w ${WRKDIR} ]; then				\
			${RM} -rf ${WRKDIR};				\
		else							\
			${ECHO_MSG} "${_PKGSRC_IN}> ${WRKDIR} not writable, skipping"; \
		fi;							\
	fi
.ifdef WRKOBJDIR
	-${_PKG_SILENT}${_PKG_DEBUG}					\
	${RMDIR} ${BUILD_DIR} 2>/dev/null;				\
	${RM} -f ${WRKDIR_BASENAME}
.endif
.else
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR}/.*_done .SizeAll .SizePkg .build_info 	\
		.build_version .DESCR .PLIST
.endif
.endif


.if !target(clean-depends)
clean-depends:
.if defined(BUILD_DEPENDS) || defined(DEPENDS)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for i in `${MAKE} ${MAKEFLAGS} CLEAN_DEPENDS_LIST_TOP=YES clean-depends-list | ${SED} -e 's;\.\./[^ ]*; ;g' | ${TR} -s "[:space:]" "\n" | sort -u` ;\
	do 								\
		cd ${.CURDIR}/../../$$i &&				\
		${MAKE} ${MAKEFLAGS} CLEANDEPENDS=NO clean;		\
	done
.endif
.endif


# The clean-depends-list target will produce a list of all 
# BUILD_DEPENDS and DEPENDS packages.  
# As each *DEPENDS package is visited, it is added to the 
# CLEAN_DEPENDS_LIST_SEEN variable.  Once a pkg is in the list
# it will not be visited again.  This prevents traversing the same
# part of the dependency tree multiple times.  Each depending package
# ends up in the list twice.  Once as the relative path from the depending
# package and once as the path from pkgsrc.  Eg, "../../foo/bar foo/bar"
# The "../../foo/bar" version is later removed from the list in the
# clean-depends target.  The remaining bit of redundancy is that some
# packages list their depends as "../bar" instead of "../../foo/bar"
# In this case its possible for a dependency to be visited twice.

.if !target(clean-depends-list)
clean-depends-list:
.if defined(BUILD_DEPENDS) || defined(DEPENDS)
	@for dir in `${ECHO} ${BUILD_DEPENDS:C/^[^:]*://:C/:.*//}	\
			${DEPENDS:C/^[^:]*://:C/:.*//} |		\
			${TR} '\040' '\012' `; do			\
		case "$$CLEAN_DEPENDS_LIST_SEEN" in			\
		*" "$$dir" "*)  ;; 					\
		*) 							\
			CLEAN_DEPENDS_LIST_SEEN=" $$dir `cd ${.CURDIR} ; cd $$dir && ${MAKE} ${MAKEFLAGS} CLEAN_DEPENDS_LIST_SEEN="$$CLEAN_DEPENDS_LIST_SEEN" CLEAN_DEPENDS_LIST_TOP=NO clean-depends-list)`";\
			;;						\
		esac							\
	done ;								\
	if [ "${CLEAN_DEPENDS_LIST_TOP}" != "YES" ]; then		\
		echo " ${PKGPATH} $$CLEAN_DEPENDS_LIST_SEEN";		\
	else								\
		echo " $$CLEAN_DEPENDS_LIST_SEEN";			\
	fi
.else
	@if [ "${CLEAN_DEPENDS_LIST_TOP}" != "YES" ]; then		\
		echo " ${PKGPATH} $$CLEAN_DEPENDS_LIST_SEEN";		\
	else								\
		echo " $$CLEAN_DEPENDS_LIST_SEEN";			\
	fi
.endif
.endif

.if !target(pre-distclean)
pre-distclean:
	@${DO_NADA}
.endif


.if !target(cleandir)
cleandir: clean
.endif


.if !target(distclean)
distclean: pre-distclean clean
	${_PKG_SILENT}${ECHO_MSG} "${_PKGSRC_IN}> Dist cleaning for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${_DISTDIR} ]; then		\
		cd ${_DISTDIR} &&					\
		${TEST} -z "${DISTFILES}" || ${RM} -f ${DISTFILES};	\
		${TEST} -z "${PATCHFILES}" || ${RM} -f ${PATCHFILES};	\
	fi
.if defined(DIST_SUBDIR)
	-${_PKG_SILENT}${_PKG_DEBUG}${RMDIR} ${_DISTDIR}  
.endif
	-${_PKG_SILENT}${_PKG_DEBUG}${RM} -f README.html
.endif

# Prints out a list of files to fetch (useful to do a batch fetch)

# are we called from bsd.pkg.subdir.mk (i.e. do we scan all dirs anyway)? XXX
.ifdef(_THISDIR_)
RECURSIVE_FETCH_LIST?=	NO
.else
RECURSIVE_FETCH_LIST?=	YES
.endif

.if !target(fetch-list)
fetch-list:
	@${MAKE} ${MAKEFLAGS} fetch-list-recursive RECURSIVE_FETCH_LIST=${RECURSIVE_FETCH_LIST} | sort -u
.endif # !target(fetch-list)

.if !target(fetch-list-recursive)
fetch-list-recursive:
	@${MAKE} ${MAKEFLAGS} fetch-list-one-pkg
.if ${RECURSIVE_FETCH_LIST} != "NO"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for dir in `${ECHO} ${BUILD_DEPENDS:C/^[^:]*://:C/:.*//}	\
				  ${DEPENDS:C/^[^:]*://:C/:.*//} |	\
		    ${TR} '\040' '\012' | sort -u` ; do			\
		cd ${.CURDIR}/$$dir &&					\
		${MAKE} ${MAKEFLAGS} fetch-list-recursive;		\
	done
.endif # ${RECURSIVE_FETCH_LIST} != "NO"
.endif # !target(fetch-list-recursive)

.if !target(fetch-list-one-pkg)
fetch-list-one-pkg:
	@${MKDIR} ${_DISTDIR}
	@[ -z "${_DISTDIR}" ] || ${ECHO} "${MKDIR} ${_DISTDIR}"
.if defined(DISTFILES)
	@(cd ${_DISTDIR};						\
	for file in "" ${DISTFILES}; do					\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		bfile=`${BASENAME} $$file`;				\
		if [ ! -f $$file -a ! -f $$bfile ]; then		\
			${ECHO} -n "cd ${_DISTDIR} && [ -f $$file -o -f $$bfile ] || "; \
			for site in "" `${SORTED_MASTER_SITES_CMD}`; do	\
				if [ "X$$site" = X"" ]; then continue; fi; \
				${ECHO} -n ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${file} "${FETCH_AFTER_ARGS}" '|| '; \
			done;						\
			${ECHO} "${ECHO} $${file} not fetched";		\
		fi							\
	done)
.endif # DISTFILES
.if defined(PATCHFILES)
	@(cd ${_DISTDIR};						\
	for file in "" ${PATCHFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		bfile=`${BASENAME} $$file`;				\
		if [ ! -f $$file -a ! -f $$bfile ]; then		\
			${ECHO} -n "cd ${_DISTDIR} && [ -f $$file -o -f $$bfile ] || "; \
			for site in ${PATCH_SITES}; do			\
				${ECHO} -n ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${file} "${FETCH_AFTER_ARGS}" '|| '; \
			done;						\
			${ECHO} "${ECHO} $${file} not fetched";		\
		fi							\
	done)
.endif # defined(PATCHFILES)
.endif # !target(fetch-list-one-pkg)

# Checksumming utilities

.if !target(makesum)
makesum: fetch
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${FILESDIR}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${MD5_FILE} ]; then ${RM} -f ${MD5_FILE}; fi
	@${ECHO} -n "$$" > ${MD5_FILE};					\
		${ECHO} -n "NetBSD" >> ${MD5_FILE}; 			\
		${ECHO} "$$" >> ${MD5_FILE};				\
		${ECHO} "" >> ${MD5_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${DISTDIR};			\
	for sumfile in "" ${_CKSUMFILES}; do				\
		if [ "X$$sumfile" = "X" ]; then continue; fi;		\
		${MD5} $$sumfile >> ${MD5_FILE};			\
	done
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for ignore in "" ${_IGNOREFILES}; do				\
		if [ "X$$ignore" = "X" ]; then continue; fi;		\
		${ECHO} "MD5 ($$ignore) = IGNORE" >> ${MD5_FILE};	\
	done
.endif

.if !target(makepatchsum)
makepatchsum:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	(${MKDIR} ${FILESDIR};						\
	${ECHO_MSG} "${_PKGSRC_IN}> Making patch checksums";			\
	if [ -f "${PATCH_SUM_FILE}" ]; then				\
		${AWK} -- '{print ; exit}' < ${PATCH_SUM_FILE} > ${PATCH_SUM_FILE}.new; \
	else								\
		${ECHO} -n "$$" > ${PATCH_SUM_FILE}.new;		\
		${ECHO} -n "NetBSD" >> ${PATCH_SUM_FILE}.new;		\
		${ECHO} "$$" >> ${PATCH_SUM_FILE}.new;			\
	fi;								\
	${ECHO} "" >> ${PATCH_SUM_FILE}.new;				\
	havepatches=0;							\
	if [ -d ${PATCHDIR} ]; then					\
		cd ${PATCHDIR};						\
		for sumfile in "" patch-*; do				\
			if [ "X$$sumfile" = "X" ]; then continue; fi;	\
			if [ "X$$sumfile" = "Xpatch-*" ]; then break; fi; \
			case $$sumfile in				\
				patch-local-*) ;;			\
				*.orig) continue ;;			\
				*)	${ECHO} "MD5 ($$sumfile) = `${SED} -e '/\$$NetBSD.*/d' $$sumfile | ${MD5}`" >> ${PATCH_SUM_FILE}.new; \
					havepatches=1 ;;		\
			esac;						\
		done;							\
	fi;								\
	if [ $$havepatches = 0 ]; then					\
		if [ -f "${PATCH_SUM_FILE}" ]; then			\
			${ECHO} "This placeholder file is generated by the \`\`makepatchsum'' target" >> ${PATCH_SUM_FILE}.new; \
			${ECHO} "whenever the patches directory is empty or missing. Its purpose" >> ${PATCH_SUM_FILE}.new; \
			${ECHO} "is to ensure that the presence of any obsolete patches will cause" >> ${PATCH_SUM_FILE}.new; \
			${ECHO} "the proper error to be emitted at build time." >> ${PATCH_SUM_FILE}.new; \
			${ECHO_MSG} "=> placeholder patch-sum file created"; \
		else							\
			${RM} -f ${PATCH_SUM_FILE}.new;			\
			${ECHO_MSG} "=> no patch-sum file created";	\
			exit 0;						\
		fi;							\
	fi;								\
	if cmp -s ${PATCH_SUM_FILE}.new ${PATCH_SUM_FILE}; then		\
		${RM} -f ${PATCH_SUM_FILE}.new;				\
		${ECHO_MSG} "=> patch-sum file unchanged";		\
	else								\
		${MV} ${PATCH_SUM_FILE}.new ${PATCH_SUM_FILE};		\
	fi)
.endif

.if !target(checksum)
checksum: fetch
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${MD5_FILE} ]; then					\
		${ECHO_MSG} "=> No MD5 checksum file.";			\
	else								\
		(cd ${DISTDIR}; OK="true";				\
		  for file in "" ${_CKSUMFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM=`${MD5} < $$file`;			\
			CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} "=> No checksum recorded for $$file."; \
				OK="false";				\
			elif [ "$$CKSUM2" = "IGNORE" ]; then		\
				${ECHO_MSG} "=> Checksum for $$file is set to IGNORE in md5 file even though"; \
				${ECHO_MSG} "   the file is not in the "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM" = "$$CKSUM2" ]; then		\
				${ECHO_MSG} "=> Checksum OK for $$file."; \
			else						\
				${ECHO_MSG} "=> Checksum mismatch for $$file."; \
				OK="false";				\
			fi;						\
		  done;							\
		  for file in "" ${_IGNOREFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} "=> No checksum recorded for $$file, file is in "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM2" != "IGNORE" ]; then		\
				${ECHO_MSG} "=> Checksum for $$file is not set to IGNORE in md5 file even though"; \
				${ECHO_MSG} "   the file is in the "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			fi;						\
		  done;							\
		  if [ "$$OK" != "true" ]; then				\
			${ECHO_MSG} "Make sure the Makefile and md5 file (${MD5_FILE})"; \
			${ECHO_MSG} "are up to date.  If you want to override this check, type"; \
			${ECHO_MSG} "\"${MAKE} NO_CHECKSUM=yes [other args]\"."; \
			exit 1;						\
		  fi) ;							\
	fi
.endif


# Install binary pkg, without strict uptodate-check first
# (XXX should be able to snarf via FTP. Later...)
bin-install:
	@if [ -f ${PKGFILE} ] ; then 					\
		${ECHO_MSG} "Installing from binary pkg ${PKGFILE}" ;	\
		${PKG_ADD} ${PKGFILE} ; 				\
	else 				 				\
		${SHCOMMENT} Cycle through some FTP server here ;\
		${ECHO_MSG} "Installing from source" ;			\
		${MAKE} ${MAKEFLAGS} package &&				\
		${MAKE} ${MAKEFLAGS} clean ;				\
	fi


################################################################
# The special package-building targets
# You probably won't need to touch these
################################################################

# Set to "html" by the README.html target (and passed via build-depends-list
# and run-depends-list)
PACKAGE_NAME_TYPE?=	name

# Nobody should want to override this unless PKGNAME is simply bogus.

.if !target(package-name)
package-name:
.if (${PACKAGE_NAME_TYPE} == "html")
	@${ECHO} '<a href="../../${PKGPATH:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}/README.html">${PKGNAME:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}</A>'
.else
	@${ECHO} ${PKGNAME}
.endif # PACKAGE_NAME_TYPE
.endif # !target(package-name)

# Show (recursively) all the packages this package depends on.
# If PACKAGE_DEPENDS_WITH_PATTERNS is set, print as pattern (if possible)
PACKAGE_DEPENDS_WITH_PATTERNS?=true
# To be used (-> true) ONLY if the pkg in question is known to be installed
# (i.e. when calling for pkg_create args, and for fake-pkg)
# Will probably not work with PACKAGE_DEPENDS_WITH_PATTERNS=false ...
PACKAGE_DEPENDS_QUICK?=false
.if !target(run-depends-list)
run-depends-list:
.for dep in ${DEPENDS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	pkg="${dep:C/:.*//}";						\
	dir="${dep:C/[^:]*://}";					\
	cd ${.CURDIR};							\
	if ${PACKAGE_DEPENDS_WITH_PATTERNS}; then			\
		${ECHO} "$$pkg";					\
	else								\
		if cd $$dir 2>/dev/null; then				\
			${MAKE} ${MAKEFLAGS} package-name PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}; \
		else 							\
			${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
		fi;							\
	fi;								\
	if ${PACKAGE_DEPENDS_QUICK} ; then 			\
		${PKG_INFO} -qf "$$pkg" | ${AWK} '/^@pkgdep/ {print $$2}'; \
	else 							\
		if cd $$dir 2>/dev/null; then				\
			${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}; \
		else 							\
			${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
		fi;							\
	fi
.endfor
.endif # target(run-depends-list)

# Build a package but don't check the package cookie

.if !target(repackage)
repackage: pre-repackage package

pre-repackage:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PACKAGE_COOKIE}
.endif

# Build a package but don't check the cookie for installation, also don't
# install package cookie

.if !target(package-noinstall)
package-noinstall:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} PACKAGE_NOINSTALL=yes real-package
.endif

################################################################
# Dependency checking
################################################################

.if !target(install-depends)
install-depends: install-run-depends install-build-depends

install-build-depends:
.if defined(BUILD_DEPENDS)
.if !defined(NO_DEPENDS)
.for dep in ${BUILD_DEPENDS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	prog="${dep:C/:.*//}";						\
	dir="${dep:C/^[^:]*://:C/:.*$//}";				\
	if [ "${_DEPENDS_TARGET_OVERRIDE}" != "" ]; then		\
		target=${DEPENDS_TARGET};				\
	elif [ "${dep:M*\:*\:*}" != "" ]; then				\
		target="${dep:C/^[^:]*:[^:]*://}";			\
	else								\
		target=${DEPENDS_TARGET};				\
	fi;								\
	found=not;							\
	if expr "$$prog" : '.*/' >/dev/null; then			\
		if ${TEST} -e "$$prog" ; then				\
			${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} depends on file: $$prog - found"; \
			found="";					\
		else							\
			${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} depends on file: $$prog - not found"; \
		fi;							\
	else								\
		for d in ${PATH:S/:/ /g}; do				\
			if [ -x $$d/$$prog ]; then			\
				found="$$d/$$prog";			\
				break;					\
			fi						\
		done;							\
		${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} depends on executable: $$prog - $$found found"; \
	fi;								\
	if [ "$$found" = "not" ]; then					\
		${ECHO_MSG} "${_PKGSRC_IN}> Verifying $$target for $$prog in $$dir"; \
		if [ ! -d "$$dir" ]; then				\
			${ECHO_MSG} "=> No directory for $$prog.  Skipping.."; \
		else							\
			cd $$dir ;					\
			${MAKE} ${MAKEFLAGS} $$target DEPENDS_TARGET=${DEPENDS_TARGET} ;	\
			${ECHO_MSG} "${_PKGSRC_IN}> Returning to build of ${PKGNAME}"; \
		fi;							\
	fi
.endfor	# BUILD_DEPENDS
.endif	# !NO_DEPENDS
.else	# !BUILD_DEPENDS
	@${DO_NADA}
.endif	# BUILD_DEPENDS

# Tells whether to halt execution if the object formats differ
FATAL_OBJECT_FMT_SKEW?= yes
WARN_NO_OBJECT_FMT?= yes

install-run-depends: uptodate-pkgtools
.if defined(DEPENDS)
.if !defined(NO_DEPENDS)
.for dep in ${DEPENDS}
	${_PKG_SILENT}${_PKG_DEBUG}\
	pkg="${dep:C/:.*//}";						\
	dir="${dep:C/[^:]*://:C/:.*$//}";				\
	found="`${PKG_INFO} -e \"$$pkg\" || ${TRUE}`";			\
	if [ "$$found" != "" ]; then					\
		instobjfmt=`${PKG_INFO} -B "$$pkg" | ${AWK} '/^OBJECT_FMT/ {print $$2}' | ${HEAD} -1`; \
		if [ "$$instobjfmt" = "" ]; then			\
			if [ "X${WARN_NO_OBJECT_FMT}" != "Xno" ]; then	\
				${ECHO} "WARNING: Unknown object format for installed package $$pkg - continuing"; \
			fi;						\
		elif [ "$$instobjfmt" != "${OBJECT_FMT}" ]; then	\
			${ECHO} "Installed package $$pkg is an $$instobjfmt package."; \
			${ECHO} "You are building an ${OBJECT_FMT} package, which will not inter-operate."; \
			${ECHO} "Please update the $$pkg package to ${OBJECT_FMT}"; \
			if [ "X${FATAL_OBJECT_FMT_SKEW}" != "Xno" ]; then \
				exit 1;					\
			fi;						\
		fi;							\
		if [ `${ECHO} $$found | wc -w` -gt 1 ]; then		\
			${ECHO} '***' "WARNING: Dependency on '$$pkg' expands to several installed packages " ; \
			${ECHO} "    (" `${ECHO} $$found` ")." ; 	\
			${ECHO} "    Please check if this is really intended!" ; \
		else 							\
			${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} depends on installed package: $$pkg - $${found} found"; \
		fi ; 							\
	else								\
		${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} depends on package: $$pkg"; \
		target=${DEPENDS_TARGET};				\
		${ECHO_MSG} "${_PKGSRC_IN}> Verifying $$target for $$dir"; 	\
		if [ ! -d $$dir ]; then					\
			${ECHO_MSG} "=> No directory for $$dir.  Skipping.."; \
		else							\
			cd $$dir ;					\
			${MAKE} ${MAKEFLAGS} $$target _PKGSRC_DEPS=", ${PKGNAME}${_PKGSRC_DEPS}"; \
			${ECHO_MSG} "${_PKGSRC_IN}> Returning to build of ${PKGNAME}"; \
		fi;							\
	fi
.endfor	# DEPENDS
.endif	# !NO_DEPENDS
.else	# !DEPENDS
	@${DO_NADA}
.endif	# DEPENDS

.endif

real-fetch: check-depends
.if !target(check-depends)
check-depends:
.if (defined(DEPENDS) || defined(BUILD_DEPENDS)) && \
    !defined(NO_DEPENDS) && !defined(NO_CHECK_DEPENDS) && !exists(${EXTRACT_COOKIE})
	${_PKG_SILENT}${_PKG_DEBUG}\
	${ECHO_MSG} "${_PKGSRC_IN}> Validating dependencies for ${PKGNAME}" ; \
	${MAKE} ${MAKEFLAGS} DEPENDS_TARGET=check-depends ECHO_MSG=${TRUE:Q} IGNORE_FAIL=1 _DEPENDS_TARGET_OVERRIDE=1 install-depends || \
		(${ECHO_MSG} "${_PKGSRC_IN}> ${PKGNAME} cannot build necessary dependencies."; ${FALSE})
.endif
.endif

.if !target(build-depends-list)
build-depends-list:
.for dir in ${BUILD_DEPENDS} ${DEPENDS}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	cd ${dir:C/^[^:]*://:C/:.*//};					\
	${MAKE} ${MAKEFLAGS} package-name build-depends-list PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}
.endfor
.endif

# If PACKAGES is set to the default (../../pkgsrc/packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.if !target(binpkg-list)
binpkg-list:
	@\
	cd ${PACKAGES};							\
	case ${.CURDIR} in						\
	*/pkgsrc/packages)						\
		for pkg in ${PKGREPOSITORYSUBDIR}/${PKGWILDCARD}${PKG_SUFX} ; \
		do 							\
			if [ -f "$$pkg" ] ; then			\
				pkgname=`${ECHO} $$pkg | ${SED} 's@.*/@@'`; \
				${ECHO} "<TR><TD>${MACHINE_ARCH}:<TD><a href=\"${PKG_URL}/$$pkg\">$$pkgname</a><TD>(${OPSYS} ${OS_VERSION})"; \
			fi ;						\
		done ; 							\
		;;							\
	*)								\
		cd ${PACKAGES}/../..;					\
		for i in [1-9].*/*; do  				\
			if cd ${PACKAGES}/../../$$i/${PKGREPOSITORYSUBDIR} 2>/dev/null; then \
				for j in ${PKGWILDCARD}${PKG_SUFX};	\
				do 					\
					if [ -f "$$j" ]; then		\
						${ECHO} $$i/$$j; 	\
					fi;				\
				done; 					\
			fi; 						\
		done | ${AWK} -F/ '					\
			{						\
				release = $$1;				\
				arch = $$2; 				\
				pkg = $$3;				\
				gsub("\.tgz","", pkg);			\
				if (arch != "m68k" && arch != "mipsel") {			\
					if (arch in urls)		\
						urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a>, " urls[arch]; \
					else				\
						urls[arch "/" pkg "/" release] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/" pkg "${PKG_SUFX}\">" pkg "</a> "; \
				}					\
			} 						\
			END { 						\
				for (av in urls) {			\
					split(av, ava, "/");		\
					arch=ava[1];			\
					pkg=ava[2];			\
					release=ava[3];			\
					print "<TR><TD>" arch ":<TD>" urls[av] "<TD>(${OPSYS} " release ")"; \
				}					\
			}' | sort					\
		;;							\
	esac
.endif

################################################################
# Everything after here are internal targets and really
# shouldn't be touched by anybody but the release engineers.
################################################################

# This target generates an index entry suitable for aggregation into
# a large index.  Format is:
#
# distribution-name|package-path|installation-prefix|comment| \
#  description-file|maintainer|categories|build deps|run deps|for arch
#
.if !target(describe)
describe:
	@${ECHO} -n "${PKGNAME}|${.CURDIR}|";				\
	${ECHO} -n "${PREFIX}|";					\
	if [ -f ${COMMENT} ]; then					\
		${ECHO} -n "`${CAT} ${COMMENT}`";			\
	else								\
		${ECHO} -n "** No Description";				\
	fi;								\
	if [ -f ${DESCR_SRC} ]; then					\
		${ECHO} -n "|${DESCR_SRC}";				\
	else								\
		${ECHO} -n "|/dev/null";				\
	fi;								\
	${ECHO} -n "|${MAINTAINER}|${CATEGORIES}|";			\
	case "A${BUILD_DEPENDS}B${DEPENDS}C" in	\
		ABC) ;;							\
		*) cd ${.CURDIR} && ${ECHO} -n `${MAKE} ${MAKEFLAGS} build-depends-list|sort -u`;; \
	esac;								\
	${ECHO} -n "|";							\
	if [ "${DEPENDS}" != "" ]; then				\
		*) cd ${.CURDIR} && ${ECHO} -n `${MAKE} ${MAKEFLAGS} run-depends-list|sort -u`;; \
	fi;								\
	${ECHO} -n "|";							\
	if [ "${ONLY_FOR_ARCHS}" = "" ]; then				\
		${ECHO} -n "any";					\
	else								\
		${ECHO} -n "${ONLY_FOR_ARCHS}";				\
	fi;								\
	${ECHO} -n "|";							\
	if [ "${NOT_FOR_OPSYS}" = "" ]; then				\
		${ECHO} -n "any";					\
	else								\
		${ECHO} -n "not ${NOT_FOR_OPSYS}";			\
	fi;								\
	${ECHO} ""
.endif

.if !target(readmes)
readmes:	readme
.endif

# This target is used to generate README.html files
.if !target(readme)
FTP_PKG_URL_HOST?=	ftp://ftp.netbsd.org
FTP_PKG_URL_DIR?=	/pub/NetBSD/packages

readme:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} README.html PKG_URL=${FTP_PKG_URL_HOST}${FTP_PKG_URL_DIR}
.endif

# This target is used to generate README.html files, very like "readme"
# However, a different target was used for ease of use.
.if !target(cdrom-readme)
CDROM_PKG_URL_HOST?=	file://localhost
CDROM_PKG_URL_DIR?=	/usr/pkgsrc/packages

cdrom-readme:
	@cd ${.CURDIR} && ${MAKE} ${MAKEFLAGS} README.html PKG_URL=${CDROM_PKG_URL_HOST}${CDROM_PKG_URL_DIR}
.endif

README_NAME=	${TEMPLATES}/README.pkg

# set up the correct license information as a sed expression
.ifdef LICENSE
SED_LICENSE_EXPR=       -e 's|%%LICENSE%%|<p>Please note that this package has a ${LICENSE} license.</p>|'
.else
SED_LICENSE_EXPR=       -e 's|%%LICENSE%%||'
.endif

# set up the "more info URL" information as a sed expression
.ifdef HOMEPAGE
SED_HOMEPAGE_EXPR=       -e 's|%%HOMEPAGE%%|<p>This package has a home page at <a HREF="${HOMEPAGE}">${HOMEPAGE}</a>.</p>|'
.else
SED_HOMEPAGE_EXPR=       -e 's|%%HOMEPAGE%%||'
.endif

.PHONY: README.html
README.html: .PRECIOUS
	@${MAKE} ${MAKEFLAGS} build-depends-list PACKAGE_NAME_TYPE=html | sort -u >> $@.tmp1
	@[ -s $@.tmp1 ] || ${ECHO} "<I>(none)</I>" >> $@.tmp1
	@${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_NAME_TYPE=html | sort -u >> $@.tmp2
	@[ -s $@.tmp2 ] || ${ECHO} "<I>(none)</I>" >> $@.tmp2
	@${ECHO} '${PKGNAME:S/&/\&amp;/g:S/>/\&gt;/g:S/</\&lt;/g}' >> $@.tmp3
	@${MAKE} ${MAKEFLAGS} binpkg-list  >> $@.tmp4
	@[ -s $@.tmp4 ] || ${ECHO} "<TR><TD><I>(no precompiled binaries available)</I>" >> $@.tmp4
	@${SED} -e 's|%%PORT%%|${PKGPATH}|g' \
		-e '/%%PKG%%/r $@.tmp3'					\
		-e '/%%PKG%%/d'						\
		${SED_LICENSE_EXPR}					\
		${SED_HOMEPAGE_EXPR}					\
		-e '/%%COMMENT%%/r ${PKGDIR}/COMMENT'			\
		-e '/%%COMMENT%%/d'					\
		-e '/%%BUILD_DEPENDS%%/r $@.tmp1'			\
		-e '/%%BUILD_DEPENDS%%/d'				\
		-e '/%%RUN_DEPENDS%%/r $@.tmp2'				\
		-e '/%%RUN_DEPENDS%%/d'					\
		-e '/%%BIN_PKGS%%/r $@.tmp4'				\
		-e '/%%BIN_PKGS%%/d'					\
		${README_NAME} >> $@.tmp
	@cmp -s $@.tmp $@ || 						\
		(${ECHO_MSG} "${_PKGSRC_IN}> Creating README.html for ${_THISDIR_}${PKGNAME}"; \
		${MV} -f $@.tmp $@)
	@${RM} -f $@.tmp $@.tmp1 $@.tmp2 $@.tmp3 $@.tmp4 $@.tmp5

.if !target(show-pkgtools-version)
show-pkgtools-version:
	@${ECHO} ${PKGTOOLS_VERSION}
.endif

# convenience target, to display make variables from command line
# i.e. "make show-var VARNAME=var", will print var's value
show-var:
	@${ECHO} "${${VARNAME}}"

.if !target(print-build-depends-list)
print-build-depends-list:
.if defined(BUILD_DEPENDS) || defined(DEPENDS)
	@${ECHO} -n 'This package requires package(s) "'
	@${ECHO} -n `${MAKE} ${MAKEFLAGS} build-depends-list | sort -u`
	@${ECHO} '" to build.'
.endif
.endif

.if !target(print-run-depends-list)
print-run-depends-list:
.if defined(DEPENDS)
	@${ECHO} -n 'This package requires package(s) "'
	@${ECHO} -n `${MAKE} ${MAKEFLAGS} run-depends-list | sort -u`
	@${ECHO} '" to run.'
.endif
.endif


# Stat all the files of one pkg and sum the sizes up. 
# 
# XXX This is intended to be run before pkg_create is called, so the
# existance of ${PLIST} can be assumed as granted.
print-pkg-size-this:
	@${SHCOMMENT} "This pkg's files" ;				\
	${AWK} 'BEGIN { base = "${PREFIX}/" }				\
		/^@cwd/ { base = $$2 "/" }				\
		/^@ignore/ { next }					\
		NF == 1 { print base $$1 }'				\
		<${PLIST} 						\
	| sort -u							\
	| ${SED} -e 's, ,\\ ,g'						\
	| xargs ls -ld							\
	| ${AWK} 'BEGIN { sum=0; }					\
		  { sum+=$$5; }						\
		  END { printf("%d\n", sum); }'

# Sizes of required pkgs (only)
# 
# XXX This is intended to be run before pkg_create is called, so the
# dependencies are all installed
print-pkg-size-depends:
	@${MAKE} ${MAKEFLAGS} print-pkg-size-depends-help 		\
	| ${AWK} 'BEGIN { sum=0; }					\
		  { sum+=$$1; }						\
		  END { printf("%d\n", sum); }'
# need this in a make look to prevent the shell clobbering the depends
# also includes size of depends of depends (XXX)
print-pkg-size-depends-help:
.for dep in ${DEPENDS}
	@pkg="${dep:C/:.*//}";						\
	${PKG_INFO} -qS "$$pkg"
.endfor


###
### Automatic PLIST generation
###  - files & symlinks first
###  - @exec/@unexec calls are added for info files
###  - @dirrm statements last
###  - empty directories are handled properly
###  - dirs from mtree files are excluded
###
### Usage:
###  - make install
###  - make print-PLIST | brain >pkg/PLIST
###

# Common (system) directories not to generate @dirrm statements for
# Reads MTREE_FILE and extracts a list of sed commands that will
# sort out which directories NOT to include into the PLIST @dirrm list
.if make(print-PLIST)
COMMON_DIRS!= 	${AWK} 'BEGIN  { 				\
			i=0; 					\
			stack[i]="${PREFIX}" ; 			\
			cwd=""; 				\
		} 						\
		! ( /^\// || /^\#/ || /^$$/ ) { 		\
			if ( $$1 == ".." ){ 			\
				i=i-1;				\
				cwd = stack[i];			\
			} else if ( $$1 == "." ){ 		\
			} else {				\
				stack[i] = cwd ;		\
				if ( i == 0 ){ 			\
					cwd = $$1 ; 		\
				} else {			\
					cwd = cwd "\\\\/" $$1 ; \
				} 				\
				print "-e \"/^" cwd "$$$$/d\"";	\
				i=i+1 ; 			\
			} 					\
		} 						\
	' <${MTREE_FILE}
.endif


# scan $PREFIX for any files/dirs modified since the package was extracted
# will emit "@exec mkdir"-statements for empty directories
# XXX will fail for data files that were copied using tar (e.g. emacs)!
# XXX should check $LOCALBASE and $X11BASE, and add @cwd statements

.if !target(print-PLIST)
print-PLIST:
	@${ECHO} '@comment $$'NetBSD'$$'
	@shlib_type=`${MAKE} ${MAKEFLAGS} show-shlib-type`;		\
	RM_ELFLIBS='';							\
	case "$$shlib_type" in						\
	"ELF")								\
		RMELFLIBS='-e /.*\/lib[^\/]*\.so\.[0-9]*$$/d		\
			   -e /.*\/lib[^\/]*\.so$$/d' ;			\
	esac ;								\
	${FIND} ${PREFIX}/. -newer ${EXTRACT_COOKIE} \! -type d 	\
	 | ${SED}							\
		-e  s@${PREFIX}/./@@ 					\
		-e  s@${OPSYS}@\$${OPSYS}@ 				\
		-e  s@${OS_VERSION}@\$${OS_VERSION}@ 			\
		-e  s@${MACHINE_ARCH}@\$${MACHINE_ARCH}@ 		\
		-e  s@${MACHINE_GNU_ARCH}@\$${MACHINE_GNU_ARCH}@	\
		-e  s@${MACHINE_GNU_PLATFORM}@\$${MACHINE_GNU_PLATFORM}@ \
		-e  s@${LOWER_VENDOR}@\$${LOWER_VENDOR}@ 		\
		-e  s@${LOWER_OPSYS}@\$${LOWER_OPSYS}@ 			\
		-e  s@${PKGNAME}@\$${PKGNAME}@ 				\
		$$RMELFLIBS 						\
	 | sort								\
	 | ${AWK} '							\
		{ 							\
		  if (/.info$$/) {					\
		    print "\@unexec install-info --delete --info-dir=%D/info %D/" $$1; \
		    print $$1;						\
		    print "\@exec install-info --info-dir=%D/info %D/" $$1; \
		  } else if (!/^info\/dir$$/) {				\
		    print $$1;						\
		  }							\
		}'
	@for i in `${FIND} ${PREFIX}/. -newer ${EXTRACT_COOKIE} -type d	\
			| ${SED}					\
				-e s@${PREFIX}/./@@			\
				-e '/^${PREFIX:S/\//\\\//g}\/.$$/d'	\
			| sort -r | ${SED} ${COMMON_DIRS}` ;		\
	do								\
		if [ `ls -la ${PREFIX}/$$i | wc -l` = 3 ]; then		\
			${ECHO} @exec /bin/mkdir -p ${PREFIX}/$$i ;	\
		fi ;							\
		${ECHO} @dirrm $$i ;					\
	done								\
	| ${SED}							\
		-e  s@${OPSYS}@\$${OPSYS}@ 				\
		-e  s@${OS_VERSION}@\$${OS_VERSION}@ 			\
		-e  s@${MACHINE_ARCH}@\$${MACHINE_ARCH}@ 		\
		-e  s@${MACHINE_GNU_ARCH}@\$${MACHINE_GNU_ARCH}@	\
		-e  s@${MACHINE_GNU_PLATFORM}@\$${MACHINE_GNU_PLATFORM}@ \
		-e  s@${LOWER_VENDOR}@\$${LOWER_VENDOR}@ 		\
		-e  s@${LOWER_OPSYS}@\$${LOWER_OPSYS}@ 			\
		-e  s@${PKGNAME}@\$${PKGNAME}@ 
.endif # target(print-PLIST)


# Fake installation of package so that user can pkg_delete it later.
# Also, make sure that an installed package is recognized correctly in
# accordance to the @pkgdep directive in the packing lists

.if !target(fake-pkg)
fake-pkg: ${PLIST} ${DESCR}
	${_PKG_SILENT}${_PKG_DEBUG}\
	if [ ! -f ${PLIST} -o ! -f ${COMMENT} -o ! -f ${DESCR} ]; then \
		${ECHO} "** Missing package files for ${PKGNAME} - installation not recorded."; \
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}\
	if [ ! -d ${PKG_DBDIR} ]; then	\
		${RM} -f ${PKG_DBDIR};					\
		${MKDIR} ${PKG_DBDIR};					\
	fi
.if defined(FORCE_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_DELETE} -O ${PKGNAME}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${PKG_DBDIR}/${PKGNAME}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${BUILD_VERSION_FILE} ${BUILD_INFO_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${SIZE_PKG_FILE} ${SIZE_ALL_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}\
	files="";				\
	for f in ${.CURDIR}/Makefile ${FILESDIR}/* ${PKGDIR}/*; do	\
		if [ -f $$f ]; then					\
			files="$$files $$f";				\
		fi;							\
	done;								\
	if [ -f ${PATCH_SUM_FILE} ]; then				\
		for f in `${AWK} '$$1 == "MD5" { gsub("[()]", "", $$2); print $$2 }' < ${PATCH_SUM_FILE}`; do \
			if [ -f $$f ]; then				\
				files="$$files ${PATCHDIR}/$$f";	\
			fi;						\
		done;							\
	fi;								\
	if [ -d ${PATCHDIR} ]; then					\
		for f in ${PATCHDIR}/patch-*; do			\
			case $$f in					\
			*.orig|*.rej|*~) ;;				\
			${PATCHDIR}/patch-local-*)			\
				files="$$files $$f" ;;			\
			esac;						\
		done;							\
	fi;								\
	${GREP} '\$$NetBSD' $$files | ${SED} -e 's|^${PKGSRCDIR}/||' > ${BUILD_VERSION_FILE};
.for def in ${BUILD_DEFS}
	@${ECHO} ${def}=	${${def}:Q} | ${SED} -e 's|PATH=[^ 	]*|PATH=...|' >> ${BUILD_INFO_FILE}
.endfor
	@${ECHO} "CC=	${CC}-`${CC} --version`" >> ${BUILD_INFO_FILE}
.ifdef USE_PERL5
	@${ECHO} "PERL=	`${LOCALBASE}/bin/perl --version | ${GREP} 'This is perl'`" >> ${BUILD_INFO_FILE}
.endif
.ifdef USE_GMAKE
	@${ECHO} "GMAKE=	`${GMAKE} --version | ${GREP} version`" >> ${BUILD_INFO_FILE}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}\
	${ECHO} "_PKGTOOLS_VER=${PKGTOOLS_VERSION}" >> ${BUILD_INFO_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}\
	size_this=`${MAKE} ${MAKEFLAGS} print-pkg-size-this`;		\
	size_depends=`${MAKE} ${MAKEFLAGS} print-pkg-size-depends`;	\
	${ECHO} $$size_this >${SIZE_PKG_FILE};				\
	expr $$size_this + $$size_depends >${SIZE_ALL_FILE} || ${TRUE}
	${_PKG_SILENT}${_PKG_DEBUG}					\
		if [ ! -d ${PKG_DBDIR}/${PKGNAME} ]; then		\
		${ECHO_MSG} "${_PKGSRC_IN}> Registering installation for ${PKGNAME}"; \
		${MKDIR} ${PKG_DBDIR}/${PKGNAME};			\
		${PKG_CREATE} ${PKG_ARGS} -O ${PKGFILE} > ${PKG_DBDIR}/${PKGNAME}/+CONTENTS; \
		${CP} ${DESCR} ${PKG_DBDIR}/${PKGNAME}/+DESC;		\
		${CP} ${COMMENT} ${PKG_DBDIR}/${PKGNAME}/+COMMENT;	\
		${CP} ${BUILD_VERSION_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_VERSION; \
		${CP} ${BUILD_INFO_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_INFO; \
		if ${TEST} -e ${SIZE_PKG_FILE}; then 			\
			${CP} ${SIZE_PKG_FILE} ${PKG_DBDIR}/${PKGNAME}/+SIZE_PKG; \
		fi ; 							\
		if ${TEST} -e ${SIZE_ALL_FILE}; then 			\
			${CP} ${SIZE_ALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+SIZE_ALL; \
		fi ; 							\
		if [ -n "${INSTALL_FILE}" ]; then			\
			if ${TEST} -e ${INSTALL_FILE}; then		\
				${CP} ${INSTALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+INSTALL; \
			fi;						\
		fi;							\
		if [ -n "${DEINSTALL_FILE}" ]; then			\
			if ${TEST} -e ${DEINSTALL_FILE}; then		\
				${CP} ${DEINSTALL_FILE} ${PKG_DBDIR}/${PKGNAME}/+DEINSTALL; \
			fi;						\
		fi;							\
		if [ -n "${REQ_FILE}" ]; then				\
			if ${TEST} -e ${REQ_FILE}; then			\
				${CP} ${REQ_FILE} ${PKG_DBDIR}/${PKGNAME}/+REQUIRE; \
			fi;						\
		fi;							\
		if [ -n "${MESSAGE_FILE}" ]; then			\
			if ${TEST} -e ${MESSAGE_FILE}; then		\
				${CP} ${MESSAGE_FILE} ${PKG_DBDIR}/${PKGNAME}/+DISPLAY; \
			fi;						\
		fi;							\
		for dep in `${MAKE} ${MAKEFLAGS} run-depends-list PACKAGE_DEPENDS_QUICK=true ECHO_MSG=${TRUE} | sort -u`; do \
			realdep="`${PKG_INFO} -e \"$$dep\" || ${TRUE}`" ; \
			if [ `${ECHO} $$realdep | wc -w` -gt 1 ]; then 				\
				${ECHO} '***' "WARNING: '$$dep' expands to several installed packages " ; \
				${ECHO} "    (" `${ECHO} $$realdep` ")." ; \
				${ECHO} "    Please check if this is really intended!" ; \
				continue ; 				\
			fi ; 						\
			if ${TEST} -z "$$realdep"; then			\
				${ECHO} "$$dep not installed - NOT registered" ; \
			elif [ -d ${PKG_DBDIR}/$$realdep ]; then	\
				if ${TEST} ! -e ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; then \
					${TOUCH} ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; \
				fi; 					\
				${AWK} 'BEGIN { found = 0; } 		\
					$$0 == "${PKGNAME}" { found = 1; } \
					{ print $$0; } 			\
					END { if (!found) { printf("%s\n", "${PKGNAME}"); }}' \
					< ${PKG_DBDIR}/$$realdep/+REQUIRED_BY > ${PKG_DBDIR}/$$realdep/reqby.$$$$; \
				${MV} ${PKG_DBDIR}/$$realdep/reqby.$$$$ ${PKG_DBDIR}/$$realdep/+REQUIRED_BY; \
				${ECHO} "${PKGNAME} requires installed package $$realdep"; \
			fi;						\
		done;							\
	fi
.endif

# Depend is generally meaningless for arbitrary packages, but if someone wants
# one they can override this.  This is just to catch people who've gotten into
# the habit of typing `${MAKE} depend all install' as a matter of course.
#
.if !target(depend)
depend:
.endif

# Same goes for tags
.if !target(tags)
tags:
.endif

# if automatic manual page compression is done by the package according
# to MANZ's value, set MANCOMPRESSED if MANZ is set
.if defined(MANCOMPRESSED_IF_MANZ) && defined(MANZ)
MANCOMPRESSED=	yes
.endif

# generate ${PLIST} from ${PLIST_SRC} by:
# - fixing list of man-pages according to MANCOMPRESSED/MANZ
#   (we don't take any notice of MANCOMPRESSED as many packages have .gz
#   pages in PLIST even when they install manpages without compressing them)
# - substituting by ${PLIST_SUBST}

.if ${OPSYS} == "NetBSD"
IMAKE_MAN_CMD=
.ifdef MANZ
MANZ_EXPRESSION= -e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]$$\)|\1.gz|' \
		-e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*[0-9ln]$$\)|\1.gz|'
.else
MANZ_EXPRESSION= -e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]\)\.gz$$|\1|' \
		-e 's|\(^\([^@/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*[0-9ln]\)\.gz$$|\1|'
.endif # MANZ
MANZ_NAWK_CMD=
.elif ${OPSYS} == "SunOS"
.ifdef USE_IMAKE
IMAKE_MAN_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*[0-9ln](\.gz)?$$/ { \
	sect = $$0; n = match(sect, "/cat[1-9ln]");			\
	sect = sprintf(".%sx", substr(sect, n + 4, 1));			\
	s = $$0; sub("/cat", "/man", s); sub("\.0(\.gz)?$$", sect, s);	\
	if (match($$0, "\.gz$$") > 0) { ext = ".gz";} else { ext = "";} \
	$$0 = sprintf("%s%s", s, ext);					\
	} { print $$0; }' |
.else
IMAKE_MAN_CMD=
.endif # USE_IMAKE
.ifdef MANZ
MANZ_NAWK_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?man[1-9ln]\/.*[1-9ln]\.gz$$/ { \
		$$0 = sprintf("%s.gz", $$0);				\
	}								\
	/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*[0-9ln]\.gz$$/ {	\
		$$0 = sprintf("%s.gz", $$0);				\
	}								\
	{ print $$0; }' |
.else
MANZ_NAWK_CMD=	${AWK} '/^([^\/]*\/)*man\/([^\/]*\/)?man[1-9ln]\/.*[1-9ln]\.gz$$/ { \
		$$0 = substr($$0, 1, length($$0) - 3);			\
	}								\
	/^([^\/]*\/)*man\/([^\/]*\/)?cat[1-9ln]\/.*[0-9ln]\.gz$$/ {	\
		$$0 = substr($$0, 1, length($$0) - 3);			\
	}								\
	{ print $$0; }' |
.endif # MANZ
MANZ_EXPRESSION= 
.endif # SunOS

plist: ${PLIST}
${PLIST}: ${PLIST_SRC}
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ -z "${PLIST_SRC}" ]; then					\
		${ECHO} "No ${PKGDIR}/PLIST or ${PKGDIR}/PLIST-{mi,md.shared,md.static}" ; \
		${ECHO} "Please set PLIST_SRC in the package Makefile.";\
	else								\
		${CAT} ${PLIST_SRC} |					\
			${MANZ_NAWK_CMD} 				\
			${IMAKE_MAN_CMD} 				\
			${SED} 	${MANZ_EXPRESSION}			\
				${PLIST_SUBST:S/=/}!/:S/$/!g/:S/^/ -e s!\\\${/}\
			> ${PLIST}; 					\
	fi

# generate ${DESCR} from ${DESCR_SRC} by:
# - Appending the homepage URL, if any

descr: ${DESCR}
${DESCR}: ${DESCR_SRC}
	@${CAT} ${DESCR_SRC} 	 >${DESCR}
.if defined(HOMEPAGE)
	@\
	${ECHO}			>>${DESCR} ; \
	${ECHO} "Homepage:"	>>${DESCR} ; \
	${ECHO} '${HOMEPAGE}'	>>${DESCR}	
.endif


#
# For bulk build targets (bulk-install, bulk-package), the
# BATCH variable must be set in /etc/mk.conf:
#
.if defined(BATCH)
.include "../../mk/bulk/bsd.bulk-pkg.mk"
.endif
