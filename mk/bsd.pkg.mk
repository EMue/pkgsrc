#	$NetBSD: bsd.pkg.mk,v 1.242 1999/04/02 21:14:12 agc Exp $
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

# Let people know this is bsd.pkg.mk, so they can set up their
# /etc/mk.conf accordingly
BSD_PKG_MK=1

# Get the operating system type
.ifndef OPSYS
OPSYS!=	uname -s
.endif

# Include any preferences, if not already included
.include "../../mk/bsd.prefs.mk"

.if defined(ONLY_FOR_ARCHS)
.for __ARCH in ${ONLY_FOR_ARCHS}
.if ${MACHINE_ARCH:M${__ARCH}} != ""
__ARCH_OK?=	1
.endif
.endfor
.else
__ARCH_OK?=	1
.endif

.if defined(NOT_FOR_ARCHS)
.for __NARCH in ${NOT_FOR_ARCHS}
.if ${MACHINE_ARCH:M${__NARCH}} != ""
.undef __ARCH_OK
.endif
.endfor
.endif

.if defined(ONLY_FOR_OPSYS)
.for __OPSYS in ${ONLY_FOR_OPSYS}
.if ${OPSYS:M${__OPSYS}} != ""
__OPSYS_OK?=	1
.endif
.endfor
.else
__OPSYS_OK?=	1
.endif

.if defined(NOT_FOR_OPSYS)
.for __NOPSYS in ${NOT_FOR_OPSYS}
.if ${OPSYS:M${__NOPSYS}} != ""
.undef __OPSYS_OK
.endif
.endfor
.endif

.if exists(${.CURDIR}/../Makefile.inc)
.include "${.CURDIR}/../Makefile.inc"
.endif

.if (${OPSYS} == "NetBSD")
DEF_UMASK?=		0022
CLEANDEPENDS?=		NO
DEINSTALLDEPENDS?=	NO
.elif (${OPSYS} == "SunOS")
DEF_UMASK?=		0022
CLEANDEPENDS?=		NO
DEINSTALLDEPENDS?=	NO
.elif (${OPSYS} == "OpenBSD")
NOMANCOMPRESS?=	yes
DEF_UMASK?=		022
.else
DEF_UMASK?=		0022
.endif

.if exists(${.CURDIR}/Makefile.${MACHINE_ARCH}-${OPSYS})
.include "${.CURDIR}/Makefile.${MACHINE_ARCH}-${OPSYS}"
.elif exists(${.CURDIR}/Makefile.${OPSYS})
.include "${.CURDIR}/Makefile.${OPSYS}"
.elif exists(${.CURDIR}/Makefile.${MACHINE_ARCH})
.include "${.CURDIR}/Makefile.${MACHINE_ARCH}"
.endif

.if (${OPSYS} == "NetBSD")
LOCALBASE?=		${DESTDIR}/usr/pkg
.else
LOCALBASE?=		${DESTDIR}/usr/local
.endif
X11BASE?=		${DESTDIR}/usr/X11R6
CROSSBASE?=		${LOCALBASE}/cross

PKGSRCDIR=		${.CURDIR}/../..
DISTDIR?=		${PKGSRCDIR}/distfiles
_DISTDIR?=		${DISTDIR}/${DIST_SUBDIR}
PACKAGES?=		${PKGSRCDIR}/packages
TEMPLATES?=		${PKGSRCDIR}/templates

.if exists(${.CURDIR}/patches.${MACHINE_ARCH}-${OPSYS})
PATCHDIR?=		${.CURDIR}/patches.${MACHINE_ARCH}-${OPSYS}
.elif exists(${.CURDIR}/patches.${OPSYS})
PATCHDIR?=		${.CURDIR}/patches.${OPSYS}
.elif exists(${.CURDIR}/patches.${MACHINE_ARCH})
PATCHDIR?=		${.CURDIR}/patches.${MACHINE_ARCH}
.else
PATCHDIR?=		${.CURDIR}/patches
.endif

.if exists(${.CURDIR}/scripts.${MACHINE_ARCH}-${OPSYS})
SCRIPTDIR?=		${.CURDIR}/scripts.${MACHINE_ARCH}-${OPSYS}
.elif exists(${.CURDIR}/scripts.${OPSYS})
SCRIPTDIR?=		${.CURDIR}/scripts.${OPSYS}
.elif exists(${.CURDIR}/scripts.${MACHINE_ARCH})
SCRIPTDIR?=		${.CURDIR}/scripts.${MACHINE_ARCH}
.else
SCRIPTDIR?=		${.CURDIR}/scripts
.endif

.if exists(${.CURDIR}/files.${MACHINE_ARCH}-${OPSYS})
FILESDIR?=		${.CURDIR}/files.${MACHINE_ARCH}-${OPSYS}
.elif exists(${.CURDIR}/files.${OPSYS})
FILESDIR?=		${.CURDIR}/files.${OPSYS}
.elif exists(${.CURDIR}/files.${MACHINE_ARCH})
FILESDIR?=		${.CURDIR}/files.${MACHINE_ARCH}
.else
FILESDIR?=		${.CURDIR}/files
.endif

.if exists(${.CURDIR}/pkg.${MACHINE_ARCH}-${OPSYS})
PKGDIR?=		${.CURDIR}/pkg.${MACHINE_ARCH}-${OPSYS}
.elif exists(${.CURDIR}/pkg.${OPSYS})
PKGDIR?=		${.CURDIR}/pkg.${OPSYS}
.elif exists(${.CURDIR}/pkg.${MACHINE_ARCH})
PKGDIR?=		${.CURDIR}/pkg.${MACHINE_ARCH}
.else
PKGDIR?=		${.CURDIR}/pkg
.endif

.if defined(USE_IMAKE) || defined(USE_MOTIF) || defined(USE_X11BASE)
.if defined(USE_LOCALBASE_FOR_X11)
PREFIX=			${LOCALBASE}
BUILD_DEPENDS+=		${X11BASE}/lib/X11/config/xpkgwedge.def:${PKGSRCDIR}/pkgtools/xpkgwedge
.else
PREFIX=			${X11BASE}
.endif
.elif defined(USE_CROSSBASE)
PREFIX=			${CROSSBASE}
NO_MTREE=		yes
.else
PREFIX=			${LOCALBASE}
.endif

.if defined(USE_GMAKE)
BUILD_DEPENDS+=		${GMAKE}:${PKGSRCDIR}/devel/gmake
MAKE_PROGRAM=		${GMAKE}
.else
MAKE_PROGRAM=		${MAKE}
.endif
.if defined(USE_PERL5)
DEPENDS+=		perl-5.00404:${PKGSRCDIR}/lang/perl5
.endif
.if defined(INFO_FILES)
USE_GTEXINFO=		yes
.endif
.if defined(USE_GTEXINFO) && !exists(/usr/bin/install-info)
DEPENDS+=		gtexinfo-3.12:${PKGSRCDIR}/devel/gtexinfo
.endif
.if defined(USE_MOTIF)
.if exists(${X11BASE}/include/Xm/Xm.h)
RUN_DEPENDS+=		${X11BASE}/include/Xm/Xm.h:${PKGSRCDIR}/x11/lesstif
.else
RUN_DEPENDS+=		${PREFIX}/include/Xm/Xm.h:${PKGSRCDIR}/x11/lesstif
BUILD_DEPENDS+=		${PREFIX}/include/Xm/Xm.h:${PKGSRCDIR}/x11/lesstif
.endif
.endif
.if defined(USE_LIBTOOL)
LIBTOOL=		${LOCALBASE}/bin/pkglibtool-1.2p1
BUILD_DEPENDS+=		${LIBTOOL}:${PKGSRCDIR}/pkgtools/pkglibtool
CONFIGURE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
MAKE_ENV+=		LIBTOOL="${LIBTOOL} ${LIBTOOL_FLAGS}"
.endif

.if exists(${PKGSRCDIR}/../Makefile.inc)
.include "${PKGSRCDIR}/../Makefile.inc"
.endif

# Don't change these!!!  These names are built into the _TARGET_USE macro,
# there is no way to refer to them cleanly from within the macro AFAIK.
EXTRACT_COOKIE?=	${WRKDIR}/.extract_done
CONFIGURE_COOKIE?=	${WRKDIR}/.configure_done
INSTALL_COOKIE?=	${WRKDIR}/.install_done
BUILD_COOKIE?=		${WRKDIR}/.build_done
PATCH_COOKIE?=		${WRKDIR}/.patch_done
PACKAGE_COOKIE?=	${WRKDIR}/.package_done

# Miscellaneous overridable commands:
GMAKE?=			gmake
XMKMF?=			xmkmf -a
.if exists(/sbin/md5)
MD5?=			/sbin/md5
.elif exists(/bin/md5)
MD5?=			/bin/md5
.elif exists(/usr/bin/md5)
MD5?=			/usr/bin/md5
.else
MD5?=			md5
.endif
MD5_FILE?=		${FILESDIR}/md5

.if defined(USE_MOTIF) || defined(USE_X11BASE) || defined(USE_X11)
LDFLAGS+=		-Wl,-R${X11BASE}/lib
.endif
LDFLAGS+=		-Wl,-R${LOCALBASE}/lib
MAKE_ENV+=		LDFLAGS="${LDFLAGS}"
CONFIGURE_ENV+=		LDFLAGS="${LDFLAGS}"

MAKE_FLAGS?=
MAKEFILE?=		Makefile
MAKE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin PREFIX=${PREFIX} LOCALBASE=${LOCALBASE} X11BASE=${X11BASE} MOTIFLIB="${MOTIFLIB}" CFLAGS="${CFLAGS}"

.if exists(/usr/bin/fetch)
FETCH_CMD?=		/usr/bin/fetch
.else
FETCH_CMD?=		/usr/bin/ftp
.endif

# By default, distfiles have no restrictions placed on them
MIRROR_DISTFILE?=	yes

TOUCH?=			/usr/bin/touch
TOUCH_FLAGS?=	-f

.if (${OPSYS} == "SunOS")
PATCH?=			${LOCALBASE}/bin/patch -b
.else
PATCH?=			/usr/bin/patch
.endif
PATCH_STRIP?=	-p0
PATCH_DIST_STRIP?=	-p0
.if defined(PATCH_DEBUG) || defined(PKG_VERBOSE)
PATCH_DEBUG_TMP=	yes
PATCH_ARGS?=	-d ${WRKSRC} -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} -E ${PATCH_DIST_STRIP}
.else
PATCH_DEBUG_TMP=	no
PATCH_ARGS?=	-d ${WRKSRC} --forward --quiet -E ${PATCH_STRIP}
PATCH_DIST_ARGS?=	-d ${WRKSRC} --forward --quiet -E ${PATCH_DIST_STRIP}
.endif
.if defined(BATCH)
PATCH_ARGS+=		--batch
PATCH_DIST_ARGS+=	--batch
.endif

.if defined(PATCH_CHECK_ONLY)
PATCH_ARGS+=	-C
PATCH_DIST_ARGS+=	-C
.endif

# New decompress and extract definitions

# If the archive has a .bz2 suffix, use bzip2 to extract information
# If EXTRACT_USING_PAX is defined, use pax in preference to (GNU) tar,
# and append 2 tar blocks of zero bytes on the end, in case the archive
# was written with a buggy version of GNU tar.

EXTRACT_SUFX?=		.tar.gz

.if ${EXTRACT_SUFX} == ".tar.bz2"
.if exists(/usr/bin/bzcat)
BZCAT=			/usr/bin/bzcat
.else
BZCAT=			${LOCALBASE}/bin/bzcat
BUILD_DEPENDS+=		${BZCAT}:${PKGSRCDIR}/archivers/bzip2
.endif # !exists bzcat
DECOMPRESS_CMD?=	${BZCAT}
.else
DECOMPRESS_CMD?=	${GZCAT}
.endif

# If this is empty, then everything gets extracted.
EXTRACT_ELEMENTS?=	

.if defined(EXTRACT_USING_PAX)
EXTRACT_CMD?=		(${DECOMPRESS_CMD} ${DOWNLOADED_DISTFILE} ; dd if=/dev/zero bs=10k count=2) | ${PAX} -r ${EXTRACT_ELEMENTS}
.else
EXTRACT_CMD?=		${DECOMPRESS_CMD} ${DOWNLOADED_DISTFILE} | /usr/bin/tar xf - ${EXTRACT_ELEMENTS}
.endif

# Figure out where the local mtree file is
.if !defined(MTREE_FILE)
.if defined(USE_IMAKE) || defined(USE_MOTIF) || defined(USE_X11BASE)
MTREE_FILE=	${PKGSRCDIR}/mk/${OPSYS}.x11.dist
.else
MTREE_FILE=	${PKGSRCDIR}/mk/${OPSYS}.pkg.dist
.endif
.endif # ! MTREE_FILE

.if (${OPSYS} == "SunOS")
MTREE_CMD?=	${LOCALBASE}/bsd/bin/mtree
.else
MTREE_CMD?=	/usr/sbin/mtree
.endif
MTREE_ARGS?=	-U -f ${MTREE_FILE} -d -e -p

.if (${OPSYS} == "NetBSD")
NEED_OWN_INSTALL_TARGET=	no
.include "../../mk/bsd.own.mk"
SHAREOWN = ${DOCOWN}
SHAREGRP = ${DOCGRP}
SHAREMODE = ${DOCMODE}
.elif (${OPSYS} == "SunOS")
NEED_OWN_INSTALL_TARGET=	no
.include "../../mk/bsd.own.mk"
SHAREOWN = ${DOCOWN}
SHAREGRP = ${DOCGRP}
SHAREMODE = ${DOCMODE}
.elif (${OPSYS} == "OpenBSD")
.include <bsd.own.mk>
MAKE_ENV+=	EXTRA_SYS_MK_INCLUDES="<bsd.own.mk>"
.endif

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
__canonical_PKGSRCDIR!=	cd ${PKGSRCDIR} && pwd -P
__canonical_CURDIR!=	cd ${.CURDIR} && pwd -P
PKGSRC_SUBDIR=		${__canonical_CURDIR:S,${__canonical_PKGSRCDIR}/,,}
BUILD_ROOT=     	${WRKOBJDIR}
BUILD_DIR?=		${WRKOBJDIR}/${PKGSRC_SUBDIR}
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
DESCR?=			${WRKDIR}/.DESCR
PLIST=			${WRKDIR}/.PLIST

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

# Files to create for versioning and build information
BUILD_VERSION_FILE=	${WRKDIR}/BuildVersion
BUILD_INFO_FILE=	${WRKDIR}/BuildInfo

.if (${OPSYS} == "SunOS")
PKG_ADD?=	${LOCALBASE}/bsd/bin/pkg_add
PKG_CREATE?=	${LOCALBASE}/bsd/bin/pkg_create
PKG_DELETE?=	${LOCALBASE}/bsd/bin/pkg_delete
PKG_INFO?=	${LOCALBASE}/bsd/bin/pkg_info
.else
PKG_ADD?=	/usr/sbin/pkg_add
PKG_CREATE?=	/usr/sbin/pkg_create
PKG_DELETE?=	/usr/sbin/pkg_delete
PKG_INFO?=	/usr/sbin/pkg_info
.endif

.ifndef PKG_ARGS
PKG_ARGS=		-v -c ${COMMENT} -d ${DESCR} -f ${PLIST} -l
PKG_ARGS+=		-b ${BUILD_VERSION_FILE} -B ${BUILD_INFO_FILE}
PKG_ARGS+=		-p ${PREFIX} -P "`${MAKE} package-depends PACKAGE_DEPENDS_WITH_PATTERNS=true|sort -u`"
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
PKG_DBDIR?=		/var/db/pkg

# shared/dynamic motif libs
MOTIFLIB?=	-L${X11BASE}/lib -L${LOCALBASE}/lib -Wl,-R${X11BASE}/lib -Wl,-R${LOCALBASE}/lib -lXm

.if (${OPSYS} == "SunOS")
AWK?=		/usr/bin/nawk
BASENAME?=	/usr/bin/basename
CAT?=		/usr/bin/cat
CHMOD?=		/usr/bin/chmod
CHOWN?=		/usr/bin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/usr/bin/cp
ECHO?=		/usr/ucb/echo
EGREP?=		/usr/xpg4/bin/egrep
FALSE?=		/usr/bin/false
FILE?=		/usr/bin/file
GREP?=		/usr/bin/grep
GTAR?=		${LOCALBASE}/bin/gtar
GUNZIP_CMD?=	${LOCALBASE}/bin/gunzip -f
GZCAT?=		${LOCALBASE}/bin/zcat
GZIP?=		-9
GZIP_CMD?=	${LOCALBASE}/bin/gzip -nf ${GZIP}
ID?=		/usr/xpg4/bin/id
IDENT?=		${LOCALBASE}/bin/ident
LDCONFIG?=	/usr/bin/true
LN?=		/usr/bin/ln
MKDIR?=		/usr/bin/mkdir -p
MV?=		/usr/bin/mv
PAX?=		/bin/pax
RM?=		/usr/bin/rm
RMDIR?=		/usr/bin/rmdir
SED?=		/usr/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/ksh
SU?=		/usr/bin/su
TAIL?=		/usr/xpg4/bin/tail
TEST?=		/usr/bin/test
TR?=		/usr/bin/tr
TRUE?=		/usr/bin/true
TYPE?=		/usr/bin/type
.else
AWK?=		/usr/bin/awk
BASENAME?=	/usr/bin/basename
CAT?=		/bin/cat
CHMOD?=		/bin/chmod
CHOWN?=		/usr/sbin/chown
CHGRP?=		/usr/bin/chgrp
CP?=		/bin/cp
ECHO?=		/bin/echo
EGREP?=		/usr/bin/egrep
FALSE?=		/usr/bin/false
FILE?=		/usr/bin/file
GREP?=		/usr/bin/grep
GTAR?=		/usr/bin/tar
GUNZIP_CMD?=	/usr/bin/gunzip -f
GZCAT?=		/usr/bin/gzcat
GZIP?=		-9
GZIP_CMD?=	/usr/bin/gzip -nf ${GZIP}
ID?=		/usr/bin/id
IDENT?=		/usr/bin/ident
LDCONFIG?=	/sbin/ldconfig
LN?=		/bin/ln
MKDIR?=		/bin/mkdir -p
MV?=		/bin/mv
PAX?=		/bin/pax
RM?=		/bin/rm
RMDIR?=		/bin/rmdir
SED?=		/usr/bin/sed
SETENV?=	/usr/bin/env
SH?=		/bin/sh
SU?=		/usr/bin/su
TAIL?=		/usr/bin/tail
TEST?=		/bin/test
TR?=		/usr/bin/tr
TRUE?=		/usr/bin/true
TYPE?=		type
.endif # !SunOS

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

# Popular master sites
MASTER_SITE_XCONTRIB+=	\
	ftp://crl.dec.com/pub/X11/contrib/%SUBDIR%/ \
	ftp://ftp.eu.net/X11/contrib/%SUBDIR%/ \
	ftp://ftp.uni-paderborn.de/pub/X11/contrib/%SUBDIR%/ \
	ftp://ftp.x.org/contrib/%SUBDIR%/

MASTER_SITE_GNU+=	\
	ftp://ftp.gnu.org/pub/gnu/%SUBDIR%/ \
	ftp://wuarchive.wustl.edu/systems/gnu/%SUBDIR%/

MASTER_SITE_PERL_CPAN+=	\
	ftp://ftp.digital.com/pub/plan/perl/CPAN/modules/by-module/%SUBDIR%/ \
	ftp://ftp.cdrom.com/pub/perl/CPAN/modules/by-module/%SUBDIR%/

MASTER_SITE_TEX_CTAN+=  \
	ftp://ftp.cdrom.com/pub/tex/ctan/%SUBDIR%/  \
	ftp://wuarchive.wustl.edu/packages/TeX/%SUBDIR%/  \
	ftp://ftp.funet.fi/pub/TeX/CTAN/%SUBDIR%/  \
	ftp://ftp.tex.ac.uk/public/ctan/tex-archive/%SUBDIR%/  \
	ftp://ftp.dante.de/tex-archive/%SUBDIR%/

MASTER_SITE_SUNSITE+=	\
	ftp://sunsite.unc.edu/pub/Linux/%SUBDIR%/ \
	ftp://ftp.infomagic.com/pub/mirrors/linux/sunsite/%SUBDIR%/ \
	ftp://ftp.funet.fi/pub/mirrors/sunsite.unc.edu/pub/Linux/%SUBDIR%/

# Empty declaration to avoid "variable MASTER_SITES recursive" error
MASTER_SITES?=
PATCH_SITES?=

# Substitute subdirectory names
MASTER_SITES:=	${MASTER_SITES:S/%SUBDIR%/${MASTER_SITE_SUBDIR}/}
PATCH_SITES:=	${PATCH_SITES:S/%SUBDIR%/${PATCH_SITE_SUBDIR}/}

# The primary backup site.
MASTER_SITE_BACKUP?=	\
	ftp://ftp.netbsd.org/pub/NetBSD/packages/distfiles/${DIST_SUBDIR}/ \
	ftp://ftp.freebsd.org/pub/FreeBSD/distfiles/${DIST_SUBDIR}/

# If the user has this set, go to the FreeBSD repository for everything.
.if defined(MASTER_SITE_FREEBSD)
MASTER_SITE_OVERRIDE=  ${MASTER_SITE_BACKUP}
.endif

# Where to put distfiles that don't have any other master site
MASTER_SITE_LOCAL?= \
	ftp://ftp.netbsd.org/pub/NetBSD/packages/distfiles/LOCAL_PORTS/ \
	ftp://ftp.freebsd.org/pub/FreeBSD/distfiles/LOCAL_PORTS/

# I guess we're in the master distribution business! :)  As we gain mirror
# sites for distfiles, add them to this list.
.if !defined(MASTER_SITE_OVERRIDE)
MASTER_SITES+=	${MASTER_SITE_BACKUP}
PATCH_SITES+=	${MASTER_SITE_BACKUP}
.else
MASTER_SITES:=	${MASTER_SITE_OVERRIDE} ${MASTER_SITES}
PATCH_SITES:=	${MASTER_SITE_OVERRIDE} ${PATCH_SITES}
.endif

# Derived names so that they're easily overridable.
DISTFILES?=		${DISTNAME}${EXTRACT_SUFX}
PKGNAME?=		${DISTNAME}

# Latest version of pkgtools required for this file.
# XXX There's a conditional test around "pkg_delete -O" for
#     _PKGTOOLS_VER>=${PKGTOOLS_PKGDB_VERSION} below which
#     should be backed out if this is bumped beyond 19990302.  - HF
PKGTOOLS_REQD=		19990119

# Version of pkgtools which support pkg_delete -O
PKGTOOLS_PKGDB_VERSION=	19990302

# Check that we're using up-to-date pkg_* tools with this file.
uptodate-pkgtools:
	${_PKG_SILENT}${_PKG_DEBUG}					\
	pkgtools_version=`${MAKE} show-pkgtools-version`;		\
	if [ $$pkgtools_version -lt ${PKGTOOLS_REQD} ]; then		\
		case ${PKGNAME} in					\
		pkg_install-*)						\
			;;						\
		*)							\
			${ECHO} "Your package tools need to be updated to `${ECHO} ${PKGTOOLS_REQD} | ${SED} -e 's|\(....\)\(..\)\(..\)|\1/\2/\3|'` versions."; \
			${ECHO} "The installed package tools were last updated on `${ECHO} $$pkgtools_version | ${SED} -e 's|\(....\)\(..\)\(..\)|\1/\2/\3|'`."; \
			${ECHO} "Please make and install the pkgsrc/pkgtools/pkg_install package."; \
			${FALSE} ;;					\
		esac							\
	fi

MAINTAINER?=		packages@netbsd.org

ALLFILES?=	${DISTFILES} ${PATCHFILES}

.if defined(IGNOREFILES)
CKSUMFILES!=	\
	for file in ${ALLFILES}; do \
		ignore=0; \
		for tmp in ${IGNOREFILES}; do \
			if [ "$$file" = "$$tmp" ]; then \
				ignore=1; \
			fi; \
		done; \
		if [ "$$ignore" = 0 ]; then \
			${ECHO} "$$file"; \
		else \
			${ECHO} ""; \
		fi; \
	done
.else
CKSUMFILES=		${ALLFILES}
.endif

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
	@${ECHO_MSG} "LIB_DEPENDS is deprecated, and must be replaced with DEPENDS."
	@${FALSE}
.endif

# Note this has to start with a capital letter (or more accurately, it
#  shouldn't match "[a-z]*"), see the target "delete-package-links" below.
PKGREPOSITORYSUBDIR?=	All
PKGREPOSITORY?=		${PACKAGES}/${PKGREPOSITORYSUBDIR}
.if exists(${PACKAGES})
PKGFILE?=		${PKGREPOSITORY}/${PKGNAME}${PKG_SUFX}
.else
PKGFILE?=		${PKGNAME}${PKG_SUFX}
.endif

CONFIGURE_SCRIPT?=	configure
CONFIGURE_ENV+=		PATH=${PATH}:${LOCALBASE}/bin:${X11BASE}/bin

.if (${OPSYS} == "NetBSD")
LOWER_OPSYS?=		netbsd
LOWER_VENDOR?=		
LOWER_ARCH?=		${MACHINE_GNU_ARCH}
.elif (${OPSYS} == "SunOS")
LOWER_OPSYS?=		solaris
LOWER_VENDOR?=		sun
LOWER_ARCH?=		${MACHINE_GNU_ARCH}
.endif

.if defined(GNU_CONFIGURE)
CONFIGURE_ARGS+=	--host=${LOWER_ARCH}-${LOWER_VENDOR}-${LOWER_OPSYS} --prefix=${PREFIX}
HAS_CONFIGURE=		yes
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
# Many ways to disable a port.
#
# If we're in BATCH mode and the port is interactive, or we're
# in interactive mode and the port is non-interactive, skip all
# the important targets.  The reason we have two modes is that
# one might want to leave a build in BATCH mode running
# overnight, then come back in the morning and do _only_ the
# interactive ones that required your intervention.
#
# Don't attempt to build ports that require Motif if you don't
# have Motif.
#
# Ignore ports that can't be resold if building for a CDROM.
#
# Don't build a port if it's restricted and we don't want to get
# into that.
#
# Don't build a port if it's broken.
################################################################

.if !defined(NO_IGNORE)
.if (defined(IS_INTERACTIVE) && defined(BATCH))
IGNORE=	"is an interactive port"
.elif (!defined(IS_INTERACTIVE) && defined(INTERACTIVE))
IGNORE=	"is not an interactive port"
.elif (defined(NO_CDROM) && defined(FOR_CDROM))
IGNORE=	"may not be placed on a CDROM: ${NO_CDROM}"
.elif (defined(RESTRICTED) && defined(NO_RESTRICTED))
IGNORE=	"is restricted: ${RESTRICTED}"
.elif ((defined(USE_IMAKE) || defined(USE_MOTIF) || \
	defined(USE_X11BASE) || defined(USE_X11)) && \
       !exists(${X11BASE}))
IGNORE=	"uses X11, but ${X11BASE} not found"
.elif defined(BROKEN)
IGNORE=	"is marked as broken: ${BROKEN}"
.elif defined(LICENSE)
.ifdef ACCEPTABLE_LICENSES
.for _lic in ${ACCEPTABLE_LICENSES}
.if ${LICENSE} == "${_lic}"
_ACCEPTABLE=	yes
.endif
.endfor	# _lic
.endif	# ACCEPTABLE_LICENSES
.ifndef _ACCEPTABLE
IGNORE=	"Unacceptable license: ${LICENSE} - set ACCEPTABLE_LICENSES in /etc/mk.conf to include ${LICENSE} to make this package"
.endif
.endif

.if defined(IGNORE)
.if defined(IGNORE_SILENT)
IGNORECMD=	${DO_NADA}
.else
IGNORECMD=	${ECHO_MSG} "===>  ${PKGNAME} ${IGNORE}."
.endif
fetch:
	@${IGNORECMD}
checksum:
	@${IGNORECMD}
extract:
	@${IGNORECMD}
patch:
	@${IGNORECMD}
configure:
	@${IGNORECMD}
all:
	@${IGNORECMD}
build:
	@${IGNORECMD}
install:
	@${IGNORECMD}
deinstall:
	@${IGNORECMD}
package:
	@${IGNORECMD}
.endif # IGNORE
.endif # !NO_IGNORE

# Add these defs to the ones dumped into +BUILD_DEFS
BUILD_DEFS+=	OPSYS OS_VERSION MACHINE_ARCH MACHINE_GNU_ARCH
BUILD_DEFS+=	CPPFLAGS CFLAGS LDFLAGS LICENSE
BUILD_DEFS+=	CONFIGURE_ENV CONFIGURE_ARGS

.if !defined(__ARCH_OK) || !defined(__OPSYS_OK)
.MAIN:	all

fetch fetch-list extract patch configure build install reinstall package checkpatch checksum makesum all:
.if defined(ONLY_FOR_ARCHS)
	@${ECHO} "This package is only for ${ONLY_FOR_ARCHS},"
.endif
.if defined(NOT_FOR_OPSYS)
	@${ECHO} "This package does not run on ${NOT_FOR_OPSYS},"
.endif
.if defined(NOT_FOR_ARCHS)
	@${ECHO} "This package does not run on ${NOT_FOR_ARCHS},"
.endif
	@${ECHO} "and you are running ${OPSYS} on ${MACHINE_ARCH}."
.else

.if defined(ALL_HOOK)
all:
	${_PKG_SILENT}${_PKG_DEBUG} \
	cd ${.CURDIR} && ${SETENV} CURDIR=${.CURDIR} DISTNAME=${DISTNAME} \
	  DISTDIR=${DISTDIR} WRKDIR=${WRKDIR} WRKSRC=${WRKSRC} \
	  PATCHDIR=${PATCHDIR} SCRIPTDIR=${SCRIPTDIR} \
	  FILESDIR=${FILESDIR} PKGSRCDIR=${PKGSRCDIR} PREFIX=${PREFIX} \
	  DEPENDS="${DEPENDS}" BUILD_DEPENDS="${BUILD_DEPENDS}" \
	  RUN_DEPENDS="${RUN_DEPENDS}" CONFLICTS="${CONFLICTS}" X11BASE=${X11BASE} \
	${ALL_HOOK}
.endif

.if !target(all)
all: build
.endif

.if !defined(DEPENDS_TARGET)
.if make(reinstall)
DEPENDS_TARGET=	reinstall
.else
DEPENDS_TARGET=	install
.endif
.endif

################################################################
# The following are used to create easy dummy targets for
# disabling some bit of default target behavior you don't want.
# They still check to see if the target exists, and if so don't
# do anything, since you might want to set this globally for a
# group of ports in a Makefile.inc, but still be able to
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
	@${ECHO_MSG} "===>  ${PKGNAME} may not be packaged: ${NO_PACKAGE}."
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
	bfile=`${BASENAME} $$file`;					\
	if [ ! -f $$file -a ! -f $$bfile ]; then			\
		if [ -h $$file -o -h $$bfile ]; then			\
			${ECHO_MSG} ">> ${_DISTDIR}/$$bfile is a broken symlink."; \
			${ECHO_MSG} ">> Perhaps a filesystem (most likely a CD) isn't mounted?"; \
			${ECHO_MSG} ">> Please correct this problem and try again."; \
			exit 1;						\
		fi ;							\
		${ECHO_MSG} ">> $$bfile doesn't seem to exist on this system."; \
		for site in $$sites; do					\
			${ECHO_MSG} ">> Attempting to fetch $$bfile from $${site}."; \
			if ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${bfile} ${FETCH_AFTER_ARGS}; then \
				if [ -n "${FAILOVER_FETCH}" -a -f ${MD5_FILE} ]; then	\
					CKSUM=`${MD5} < ${_DISTDIR}/$$bfile`; \
					CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
					if [ "$$CKSUM" = "$$CKSUM2" -o "$$CKSUM2" = "IGNORE" ]; then \
						continue 2;		\
					else				\
						${ECHO_MSG} ">> Checksum failure - trying next site."; \
					fi;				\
				else					\
					continue 2;			\
				fi;					\
			fi						\
		done;							\
		${ECHO_MSG} ">> Couldn't fetch it - please try to retrieve this";\
		${ECHO_MSG} ">> file manually into ${_DISTDIR} and try again."; \
		exit 1;							\
	fi

.if !target(do-fetch)
do-fetch:
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${_DISTDIR}
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${_DISTDIR};			\
	 sites="${MASTER_SITES}";					\
	 for file in "" ${_DISTFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		${_FETCH_FILE}						\
	 done)
.if defined(_PATCHFILES)
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${_DISTDIR};			\
	 sites="${PATCH_SITES}";					\
	 for file in "" ${_PATCHFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		${_FETCH_FILE}						\
	 done)
.endif
.endif

# This is for the use of sites which store distfiles which others may
# fetch - only fetch the distfile if it is allowed to be
# re-distributed freely
mirror-distfiles:
.if (${MIRROR_DISTFILE} == "yes")
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} fetch __ARCH_OK=1 __OPSYS_OK=1 NO_IGNORE=yes
.endif

# Extract

DOWNLOADED_DISTFILE=	${_DISTDIR}/$$file

.if !target(do-extract)
do-extract:
.ifndef NO_WRKDIR
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${WRKDIR}
	${_PKG_SILENT}${_PKG_DEBUG}${MKDIR} ${WRKDIR}
.ifdef WRKOBJDIR
	${_PKG_SILENT}${_PKG_DEBUG}					\
	${RM} -f ${WRKDIR_BASENAME};					\
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
	@${ECHO_MSG} "===>  Applying distribution patches for ${PKGNAME}"
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${_DISTDIR}; \
	  for i in ${PATCHFILES}; do \
		if [ ${PATCH_DEBUG_TMP} = yes ]; then \
			${ECHO_MSG} "===>   Applying distribution patch $$i" ; \
		fi; \
		case $$i in \
			*.Z|*.gz) \
				${GZCAT} $$i | ${PATCH} ${PATCH_DIST_ARGS} \
				|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
				;; \
			*) \
				${PATCH} ${PATCH_DIST_ARGS} < $$i \
				|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
				;; \
		esac; \
	  done)
.endif
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${PATCHDIR} ]; then \
		if [ "`${ECHO} ${PATCHDIR}/patch-*`" = "${PATCHDIR}/patch-*" ]; then \
			${ECHO_MSG} "===>   Ignoring empty patch directory"; \
			if [ -d ${PATCHDIR}/CVS ]; then \
				${ECHO_MSG} "===>   Perhaps you forgot the -P flag to cvs co or update?"; \
			fi; \
		else \
			${ECHO_MSG} "===>  Applying ${OPSYS} patches for ${PKGNAME}" ; \
			for i in ${PATCHDIR}/patch-*; do \
				case $$i in \
					*.orig|*.rej|*~) \
						${ECHO_MSG} "===>   Ignoring patchfile $$i" ; \
						;; \
					*) \
						if [ ${PATCH_DEBUG_TMP} = yes ]; then \
							${ECHO_MSG} "===>   Applying ${OPSYS} patch $$i" ; \
						fi; \
						${PATCH} ${PATCH_ARGS} < $$i \
						|| ( ${ECHO} Patch $$i failed ; exit 1 ) ; \
						;; \
				esac; \
			done; \
		fi; \
	fi
.endif

# Configure

.if !target(do-configure)
do-configure:
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/configure ]; then \
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH} \
		  ${SCRIPTDIR}/configure; \
	fi
.if defined(HAS_CONFIGURE)
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} CC="${CC}" ac_cv_path_CC="${CC}" \
	    CFLAGS="${CFLAGS}" \
	    INSTALL="`${TYPE} ${INSTALL} | ${AWK} '{ print $$NF }'` -c -o ${BINOWN} -g ${BINGRP}" \
	    INSTALL_PROGRAM="${INSTALL_PROGRAM}" \
	    ${CONFIGURE_ENV} ./${CONFIGURE_SCRIPT} ${CONFIGURE_ARGS})
.endif
.if defined(USE_IMAKE)
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${SCRIPTS_ENV} XPROJECTROOT=${X11BASE} ${XMKMF})
.endif
.endif

# Build

.if !target(do-build)
do-build:
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${ALL_TARGET})
.endif

# Install

.if !target(do-install)
do-install:
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${MAKE_PROGRAM} ${MAKE_FLAGS} -f ${MAKEFILE} ${INSTALL_TARGET})
.endif

# Package

.if !target(do-package)
do-package: ${PLIST} ${DESCR}
	${_PKG_SILENT}${_PKG_DEBUG}if ${TEST} -e ${PLIST}; then		\
		${ECHO_MSG} "===>  Building package for ${PKGNAME}";	\
		if [ -d ${PACKAGES} ]; then				\
			if [ ! -d ${PKGREPOSITORY} ]; then		\
				${MKDIR} ${PKGREPOSITORY};		\
				if [ $$? -ne 0 ]; then			\
					${ECHO_MSG} ">> Can't create directory ${PKGREPOSITORY}."; \
					exit 1;				\
				fi;					\
			fi;						\
		fi;							\
		if ${PKG_CREATE} ${PKG_ARGS} ${PKGFILE}; then		\
			if [ -d ${PACKAGES} ]; then			\
				${MAKE} ${.MAKEFLAGS} package-links;	\
			fi;						\
		else							\
			${MAKE} ${.MAKEFLAGS} delete-package;		\
			exit 1;						\
		fi;							\
	fi
.endif

# Some support rules for do-package

.if !target(package-links)
package-links:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${.MAKEFLAGS} delete-package-links
	${_PKG_SILENT}${_PKG_DEBUG}for cat in ${CATEGORIES}; do		\
		if [ ! -d ${PACKAGES}/$$cat ]; then			\
			${MKDIR} ${PACKAGES}/$$cat;			\
			if [ $$? -ne 0 ]; then				\
				${ECHO_MSG} ">> Can't create directory ${PACKAGES}/$$cat."; \
				exit 1;					\
			fi;						\
		fi;							\
		${LN} -s ../${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX} ${PACKAGES}/$$cat; \
	done;
.endif

.if !target(delete-package-links)
delete-package-links:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${PACKAGES}/[a-z]*/${PKGNAME}${PKG_SUFX};
.endif

.if !target(delete-package)
delete-package:
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} ${.MAKEFLAGS} delete-package-links
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
# This is the "generic" port target, actually a macro used from the
# six main targets.  See below for more.
################################################################

_PORT_USE: .USE
.if make(real-fetch)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} fetch-depends
.endif
.if make(real-extract)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} build-depends misc-depends
.endif
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} ${.TARGET:S/^real-/pre-/}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/${.TARGET:S/^real-/pre-/} ]; then		\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/${.TARGET:S/^real-/pre-/};		\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} ${.TARGET:S/^real-/do-/}
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} ${.TARGET:S/^real-/post-/}
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/${.TARGET:S/^real-/post-/} ]; then	\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/${.TARGET:S/^real-/post-/};	\
	fi
.if !make(real-fetch)							\
	&& (!make(real-patch) || !defined(PATCH_CHECK_ONLY))		\
	&& (!make(real-package) || !defined(PACKAGE_NOINSTALL))
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${WRKDIR}/.${.TARGET:S/^real-//}_done
.endif

root-install:
.if !defined(NO_PKG_REGISTER) && !defined(FORCE_PKG_REGISTER)
.if defined(CONFLICTS)
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${WRKDIR}/.CONFLICTS
.for conflict in ${CONFLICTS}
	${_PKG_SILENT}${_PKG_DEBUG}found="`${PKG_INFO} -e \"${conflict}\" || ${TRUE}`"; \
	if [ X"$$found" != X"" ]; then					\
		${ECHO} "$$found" >> ${WRKDIR}/.CONFLICTS;		\
	fi
.endfor
	${_PKG_SILENT}${_PKG_DEBUG}if [ -s ${WRKDIR}/.CONFLICTS ]; then \
		found=`cat ${WRKDIR}/.CONFLICTS | ${SED} -e s'|${PKG_DBDIR}/||g' | tr '\012' ' '`; \
		${ECHO_MSG} "===>  ${PKGNAME} conflicts with installed package(s): $$found found."; \
		${ECHO_MSG} "      They install the same files into the same place."; \
		${ECHO_MSG} "      Please remove $$found first with pkg_delete(1)."; \
		${RM} -f ${WRKDIR}/.CONFLICTS;				\
		exit 1;							\
	fi
.endif	# CONFLICTS
	${_PKG_SILENT}${_PKG_DEBUG}found="`${PKG_INFO} -e \"${PKGNAME:C/-[^-]*$/-*/}\" || ${TRUE}`"; \
	if [ "$$found" != "" ]; then					\
		${ECHO_MSG} "===>  $$found is already installed - perhaps an older version?"; \
		${ECHO_MSG} "      If so, you may wish to \`\`pkg_delete $$found'' and install"; \
		${ECHO_MSG} "      this port again by \`\`${MAKE} reinstall'' to upgrade it properly."; \
		${ECHO_MSG} "      If you really wish to overwrite the old package of $$found"; \
		${ECHO_MSG} "      without deleting it first, set the variable \"FORCE_PKG_REGISTER\""; \
		${ECHO_MSG} "      in your environment or the \"${MAKE} install\" command line."; \
		exit 1;							\
	fi
.endif # !NO_PKG_REGISTER && !NO_FORCE_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${SH} -c umask` != ${DEF_UMASK} ]; then \
		${ECHO_MSG} "===>  Warning: your umask is \"`${SH} -c umask`"\".; \
		${ECHO_MSG} "      If this is not desired, set it to an appropriate value (${DEF_UMASK})"; \
		${ECHO_MSG} "      and install this port again by \`\`${MAKE} deinstall reinstall''."; \
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} run-depends
.if !defined(NO_MTREE)
	${_PKG_SILENT}${_PKG_DEBUG}if [ `${ID} -u` = 0 ]; then		\
		if [ ! -f ${MTREE_FILE} ]; then				\
			${ECHO_MSG} "Error: mtree file \"${MTREE_FILE}\" is missing."; \
			exit 1;						\
		else							\
			if [ ! -d ${PREFIX} ]; then			\
				mkdir -p ${PREFIX};			\
			fi;						\
			${MTREE_CMD} ${MTREE_ARGS} ${PREFIX}/;		\
		fi;							\
	else								\
		${ECHO_MSG} "Warning: not superuser, can't run mtree."; \
		${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
	fi
.endif # !NO_MTREE
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} pre-install
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/pre-install ]; then		\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/pre-install;		\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} do-install
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${SETENV} ${MAKE_ENV} ${MAKE} ${.MAKEFLAGS} post-install
	${_PKG_SILENT}${_PKG_DEBUG}if [ -f ${SCRIPTDIR}/post-install ]; then	\
		cd ${.CURDIR} && ${SETENV} ${SCRIPTS_ENV} ${SH}		\
			${SCRIPTDIR}/post-install;	\
	fi
.for f in ${INFO_FILES}
	${ECHO} "install-info --info-dir=${PREFIX}/info ${PREFIX}/info/${f}"; \
	install-info --remove --info-dir=${PREFIX}/info ${PREFIX}/info/${f}; \
	install-info --info-dir=${PREFIX}/info ${PREFIX}/info/${f}
.endfor
	${_PKG_SILENT}(${_PKG_DEBUG}newmanpages=`${EGREP} -h		\
		'^([^/]*/)*man/([^/]*/)?(man[1-9ln]/.*\.[1-9ln]|cat[1-9ln]/.*\.0)(\.gz)?$$' \
		${PLIST_SRC} || /usr/bin/true`;				\
	if [ X"${MANCOMPRESSED}" != X"" -a X"${MANZ}" = X"" ]; then	\
		${ECHO_MSG} "===>   [Automatic manual page handling]";	\
		${ECHO_MSG} "===>   Decompressing manual pages for ${PKGNAME}";	\
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -L ${PREFIX}/$$manpage.gz ]; then		\
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
		${ECHO_MSG} "===>   [Automatic manual page handling]";	\
		${ECHO_MSG} "===>   Compressing manual pages for ${PKGNAME}"; \
		for manpage in $$newmanpages; do			\
			manpage=`${ECHO} $$manpage | ${SED} -e 's|\.gz$$||'`; \
			if [ -L ${PREFIX}/$$manpage ]; then		\
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
	fi)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} ${PLIST}
	${_PKG_SILENT}(${_PKG_DEBUG}sos=`${EGREP} -h 			\
		'.*/lib[^/]+\.so\.[0-9]+\.[0-9]+$$'			\
		${PLIST} || ${TRUE}`;					\
	if [ X"$$sos" != X"" ]; then					\
		case "${SHLIB_TYPE}" in					\
		"ELF")							\
			${ECHO_MSG} "===>   [Automatic ${SHLIB_TYPE} shared object handling]";\
			for so2 in $$sos; do				\
				so1=`${ECHO} $$so2 | ${SED} -e 's|\.[0-9]*$$||'`; \
				so0=`${ECHO} $$so1 | ${SED} -e 's|\.[0-9]*$$||'`; \
				cnt=`${EGREP} -c -x "$$so0" ${PLIST} || ${TRUE}`; \
				if [ $$cnt -eq 0 ]; then		\
					${SED} -e "s|^$$so2$$|&!$$so0|" -e 'y|!|\n|' ${PLIST} > ${PLIST}.tmp && ${MV} ${PLIST}.tmp ${PLIST}; \
					${ECHO_MSG} "${LN} -s ${PREFIX}/$$so2 ${PREFIX}/$$so0"; \
					${RM} -f ${PREFIX}/$$so0; 	\
					${LN} -s ${PREFIX}/$$so2 ${PREFIX}/$$so0; \
				fi;					\
				cnt=`${EGREP} -c -x "$$so1" ${PLIST} || ${TRUE}`; \
				if [ $$cnt -eq 0 ]; then		\
					${SED} -e "s|^$$so2$$|&!$$so1|" -e 'y|!|\n|' ${PLIST} > ${PLIST}.tmp && ${MV} ${PLIST}.tmp ${PLIST}; \
					${ECHO_MSG} "${LN} -s ${PREFIX}/$$so2 ${PREFIX}/$$so1"; \
					${RM} -f ${PREFIX}/$$so1; 	\
					${LN} -s ${PREFIX}/$$so2 ${PREFIX}/$$so1; \
				fi;					\
				if [ X"${PKG_VERBOSE}" != X"" ]; then	\
					${ECHO_MSG} "$$so2";		\
				fi;					\
			done;						\
			;;						\
		"a.out")						\
			${ECHO_MSG} "===>   [Automatic ${SHLIB_TYPE} shared object handling]";\
			if ${GREP} -c '^@exec ${LDCONFIG}$$' ${PLIST}; then \
				${ECHO} "@exec ${LDCONFIG}" >> ${PLIST}; \
				${ECHO} "@unexec ${LDCONFIG}" >> ${PLIST}; \
			fi;						\
			if [ X"${PKG_VERBOSE}" != X"" ]; then		\
				${ECHO_MSG} "$$sos";			\
				${ECHO_MSG} "Running ${LDCONFIG}";	\
			fi;						\
			${LDCONFIG};					\
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
	fi)
.ifdef MESSAGE_FILE
	@${ECHO_MSG} "===>   Please note the following:"
	@${ECHO_MSG} ""
	@${CAT} ${MESSAGE_FILE}
	@${ECHO_MSG} ""
.endif
.if !defined(NO_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} fake-pkg
.endif # !NO_PKG_REGISTER
	${_PKG_SILENT}${_PKG_DEBUG}${TOUCH} ${TOUCH_FLAGS} ${WRKDIR}/.install_done


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
	@cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-fetch
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
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-extract
${PATCH_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-patch
${CONFIGURE_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-configure
${BUILD_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-build
${INSTALL_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-install
${PACKAGE_COOKIE}:
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} real-package

# And call the macros

real-fetch: _PORT_USE
real-extract: _PORT_USE
	@${ECHO_MSG} "===>  Extracting for ${PKGNAME}"
real-patch: _PORT_USE
	@${ECHO_MSG} "===>  Patching for ${PKGNAME}"
real-configure: _PORT_USE
	@${ECHO_MSG} "===>  Configuring for ${PKGNAME}"
real-build: _PORT_USE
	@${ECHO_MSG} "===>  Building for ${PKGNAME}"
real-install: pkg-su-install
real-package: _PORT_USE

# sudo or priv are acceptable substitutes
SU_CMD?=	${SU} - root -c
PRE_ROOT_CMD?=	${TRUE}

pkg-su-install:
	@${ECHO_MSG} "===>  Installing for ${PKGNAME}"
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ `${ID} -u` = 0 ]; then					\
		${MAKE} ${.MAKEFLAGS} root-install;			\
	else								\
		if [ "X${BATCH}" != X"" ]; then				\
			${ECHO_MSG} "Warning: Batch mode, not superuser, can't run mtree."; \
			${ECHO_MSG} "Become root and try again to ensure correct permissions."; \
		else							\
			make=`${TYPE} ${MAKE} | ${AWK} '{ print $$NF }'`; \
			force="";					\
			if [ "X${FORCE_PKG_REGISTER}" != X"" ]; then	\
				force="FORCE_PKG_REGISTER=1";		\
			fi;						\
			if [ "X${PRE_ROOT_CMD}" != "X${TRUE}" ]; then	\
				${ECHO} "*** WARNING *** Running: ${PRE_ROOT_CMD}"; \
				${PRE_ROOT_CMD};			\
			fi;                                             \
			${ECHO_MSG} "Becoming root to install ${PKGNAME}.";\
			${SU_CMD} "cd ${.CURDIR}; $$make $$force ${.MAKEFLAGS} root-install"; \
                fi;							\
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
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} PATCH_CHECK_ONLY=yes ${.MAKEFLAGS} patch
.endif

# Reinstall
#
# Special target to re-run install

.if !target(reinstall)
reinstall:
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE} ${PLIST}
	${_PKG_SILENT}${_PKG_DEBUG}DEPENDS_TARGET=${DEPENDS_TARGET} ${MAKE} install
.endif

# Deinstall
#
# Special target to remove installation

.if !target(deinstall)
deinstall: uptodate-pkgtools
	@${ECHO_MSG} "===> Deinstalling for ${PKGNAME}"
.ifdef PKG_VERBOSE
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_DELETE} -v ${PKGNAME} || ${TRUE}
.else
	${_PKG_SILENT}${_PKG_DEBUG}${PKG_DELETE} ${PKGNAME} || ${TRUE}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${INSTALL_COOKIE} ${PACKAGE_COOKIE}
.if (${DEINSTALLDEPENDS} != "NO")
	${_PKG_SILENT}${_PKG_DEBUG}				\
	${PKG_INFO} -qe ${PKGNAME};				\
	if [ $$? -ne 0 ]; then					\
		${MAKE} deinstall-depends;			\
	fi
.endif # DEINSTALLDEPENDS != "NO"
.endif # target(deinstall)

# Deinstall-depends
# XXX Should be done with "pkg_delete -R"
#
# Like clean-depends, only to deinstall things
.if !target(deinstall-depends)
deinstall-depends: uptodate-pkgtools
.if defined(FETCH_DEPENDS) || defined(BUILD_DEPENDS) \
       || defined(DEPENDS) || defined(RUN_DEPENDS)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for dir in `${ECHO} ${FETCH_DEPENDS} ${BUILD_DEPENDS} ${DEPENDS} ${RUN_DEPENDS} | ${TR} '\040' '\012' | ${SED} -e 's/^[^:]*://' -e 's/:.*//' | sort -u`; do \
		if [ -d $$dir ] ; then					\
			(cd $$dir && ${MAKE} DEINSTALLDEPENDS=${DEINSTALLDEPENDS} deinstall); \
		fi							\
	done
.endif # *_DEPENDS
.endif # deinstall-depends


.endif # __ARCH_OK
       # The functions below may be useful even if _ARCH_OK is not set


################################################################
# Some more targets supplied for users' convenience
################################################################

# Cleaning up

.if !target(pre-clean)
pre-clean:
	@${DO_NADA}
.endif

.if !target(clean)
clean: pre-clean
.if (${CLEANDEPENDS} != "NO")
	${_PKG_SILENT}${_PKG_DEBUG}${MAKE} clean-depends
.endif
	@${ECHO_MSG} "===>  Cleaning for ${PKGNAME}"
.if !defined(NO_WRKDIR)
.ifdef WRKOBJDIR
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${WRKOBJDIR}/${PKGSRC_SUBDIR}
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${WRKDIR_BASENAME}
.else
	${_PKG_SILENT}${_PKG_DEBUG}if [ -d ${WRKDIR} ]; then		\
		if [ -w ${WRKDIR} ]; then				\
			${RM} -rf ${WRKDIR};				\
		else							\
			${ECHO_MSG} "===>   ${WRKDIR} not writable, skipping"; \
		fi;							\
	fi
.endif
.else
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${WRKDIR}/.*_done
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
	${_PKG_SILENT}${ECHO_MSG} "===>  Dist cleaning for ${PKGNAME}"
	${_PKG_SILENT}(${_PKG_DEBUG}if [ -d ${_DISTDIR} ]; then		\
		cd ${_DISTDIR} &&					\
		${TEST} -z "${DISTFILES}" || ${RM} -f ${DISTFILES};	\
		${TEST} -z "${PATCHFILES}" || ${RM} -f ${PATCHFILES};	\
	fi)
.if defined(DIST_SUBDIR)
	-${_PKG_SILENT}${_PKG_DEBUG}${RMDIR} ${_DISTDIR}  
.endif
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
	@${MAKE} fetch-list-recursive RECURSIVE_FETCH_LIST=${RECURSIVE_FETCH_LIST} | sort -u
.endif # !target(fetch-list)

.if !target(fetch-list-recursive)
fetch-list-recursive:
	@${MAKE} fetch-list-one-pkg
.if ${RECURSIVE_FETCH_LIST} != "NO"
	@for dir in `${ECHO} ${FETCH_DEPENDS} ${BUILD_DEPENDS} ${DEPENDS} ${RUN_DEPENDS} | ${TR} '\040' '\012' | ${SED} -e 's/^[^:]*://' -e 's/:.*//' | sort -u` ; do \
		(cd $$dir && ${MAKE} fetch-list-recursive; );		\
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
		if [ ! -f $$file -a ! -f `${BASENAME} $$file` ]; then	\
			${ECHO} -n "cd ${_DISTDIR} && [ -f $$file -o -f `${BASENAME} $$file` ] || " ; \
			for site in "" ${MASTER_SITES}; do		\
				if [ "X$$site" = X"" ]; then continue; fi; \
				${ECHO} -n ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${file} "${FETCH_AFTER_ARGS}" '|| ' ; \
			done;						\
			${ECHO} "${ECHO} $${file} not fetched";		\
		fi							\
	done)
.endif # DISTFILES
.if defined(PATCHFILES)
	@(cd ${_DISTDIR};						\
	for file in "" ${PATCHFILES}; do				\
		if [ "X$$file" = X"" ]; then continue; fi;		\
		if [ ! -f $$file -a ! -f `${BASENAME} $$file` ]; then	\
			${ECHO} -n "cd ${_DISTDIR} && [ -f $$file -o -f `${BASENAME} $$file` ] || " ; \
			for site in ${PATCH_SITES}; do			\
				${ECHO} -n ${FETCH_CMD} ${FETCH_BEFORE_ARGS} $${site}$${file} "${FETCH_AFTER_ARGS}" '|| ' ; \
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
	${_PKG_SILENT}(${_PKG_DEBUG}cd ${DISTDIR};			\
	for sumfile in "" ${_CKSUMFILES}; do				\
		if [ "X$$sumfile" = X"" ]; then continue; fi;		\
		${MD5} $$sumfile >> ${MD5_FILE};			\
	done)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	for ignore in "" ${_IGNOREFILES}; do				\
		if [ "X$$sumfile" = X"" ]; then continue; fi;		\
		${ECHO} "MD5 ($$ignore) = IGNORE" >> ${MD5_FILE};	\
	done
.endif

.if !target(checksum)
checksum: fetch
	${_PKG_SILENT}${_PKG_DEBUG}					\
	if [ ! -f ${MD5_FILE} ]; then					\
		${ECHO_MSG} ">> No MD5 checksum file.";			\
	else								\
		(cd ${DISTDIR}; OK="true";				\
		  for file in "" ${_CKSUMFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM=`${MD5} < $$file`;			\
			CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} ">> No checksum recorded for $$file."; \
				OK="false";				\
			elif [ "$$CKSUM2" = "IGNORE" ]; then		\
				${ECHO_MSG} ">> Checksum for $$file is set to IGNORE in md5 file even though"; \
				${ECHO_MSG} "   the file is not in the "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM" = "$$CKSUM2" ]; then		\
				${ECHO_MSG} ">> Checksum OK for $$file."; \
			else						\
				${ECHO_MSG} ">> Checksum mismatch for $$file."; \
				OK="false";				\
			fi;						\
		  done;							\
		  for file in "" ${_IGNOREFILES}; do			\
		  	if [ "X$$file" = X"" ]; then continue; fi; 	\
			CKSUM2=`${AWK} '$$1 == "MD5" && $$2 == "('$$file')"{print $$4;}' ${MD5_FILE}`; \
			if [ "$$CKSUM2" = "" ]; then			\
				${ECHO_MSG} ">> No checksum recorded for $$file, file is in "'$$'"{IGNOREFILES} list."; \
				OK="false";				\
			elif [ "$$CKSUM2" != "IGNORE" ]; then		\
				${ECHO_MSG} ">> Checksum for $$file is not set to IGNORE in md5 file even though"; \
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

################################################################
# The special package-building targets
# You probably won't need to touch these
################################################################

HTMLIFY=	${SED} -e 's/&/\&amp;/g' -e 's/>/\&gt;/g' -e 's/</\&lt;/g'

# Set to "html" by the README.html target (and passed via depends-list
# and package-depends)
PACKAGE_NAME_TYPE?=	name

# Nobody should want to override this unless PKGNAME is simply bogus.

.if !target(package-name)
package-name:
.if (${PACKAGE_NAME_TYPE} == "html")
	@${ECHO} '<A HREF="../../'`${MAKE} package-path | ${HTMLIFY}`'/README.html">'`${ECHO} ${PKGNAME} | ${HTMLIFY}`'</A>'
.else
	@${ECHO} '${PKGNAME}'
.endif # PACKAGE_NAME_TYPE
.endif # !target(package-name)

.if !target(package-path)
package-path:
	@pwd | sed s@`cd ${PKGSRCDIR} && pwd`/@@g
.endif

# Show (recursively) all the packages this package depends on.
# if PACKAGE_DEPENDS_WITH_PATTERNS is set, print as pattern (if possible)
PACKAGE_DEPENDS_WITH_PATTERNS?=false
.if !target(package-depends)
package-depends:
.for dep in ${DEPENDS}
	@pkg="`${ECHO} \"${dep}\" | ${SED} -e 's/:.*//'`";		\
	dir="`${ECHO} \"${dep}\" | ${SED} -e 's/[^:]*://'`";		\
	if [ -d $$dir ]; then						\
		if ${PACKAGE_DEPENDS_WITH_PATTERNS}; then		\
			${ECHO} "$$pkg";				\
		else							\
			(cd $$dir && ${MAKE} package-name PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
		fi;							\
		(cd $$dir && ${MAKE} package-depends PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
	else								\
		${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
	fi
.endfor
.for dep in ${RUN_DEPENDS}
	@pkg="`${ECHO} \"${dep}\" | ${SED} -e 's/:.*//'`";		\
	dir="`${ECHO} \"${dep}\" | ${SED} -e 's/[^:]*://'`";		\
	if [ -d $$dir ]; then						\
		(cd $$dir && ${MAKE} package-name PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
		(cd $$dir && ${MAKE} package-depends PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}); \
	else								\
		${ECHO_MSG} "Warning: \"$$dir\" non-existent -- @pkgdep registration incomplete" >&2; \
	fi
.endfor
.endif # target(package-depends)

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
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} PACKAGE_NOINSTALL=yes real-package
.endif

################################################################
# Dependency checking
################################################################

.if !target(depends)
depends: misc-depends
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} fetch-depends
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} build-depends
	${_PKG_SILENT}${_PKG_DEBUG}cd ${.CURDIR} && ${MAKE} ${.MAKEFLAGS} run-depends

.if make(fetch-depends)
DEPENDS_TMP+=	${FETCH_DEPENDS}
.endif

.if make(build-depends)
DEPENDS_TMP+=	${BUILD_DEPENDS}
.endif

.if make(run-depends)
DEPENDS_TMP+=	${RUN_DEPENDS}
.endif

_DEPENDS_USE:	.USE
.if defined(DEPENDS_TMP)
.if !defined(NO_DEPENDS)
.for i in ${DEPENDS_TMP}
	${_PKG_SILENT}${_PKG_DEBUG}prog="`${ECHO} \"${i}\" | ${SED} -e 's/:.*//'`"; \
	dir="`${ECHO} \"${i}\" | ${SED} -e 's/[^:]*://'`";		\
	if expr "$$dir" : '.*:' > /dev/null; then			\
		target=`${ECHO} $$dir | ${SED} -e 's/.*://'`;		\
		dir=`${ECHO} $$dir | ${SED} -e 's/:.*//'`;		\
	else								\
		target=${DEPENDS_TARGET};				\
	fi;								\
	found=not;							\
	if expr "$$prog" : '.*/' >/dev/null; then			\
		if ${TEST} -e "$$prog" ; then				\
			${ECHO_MSG} "===>  ${PKGNAME} depends on file: $$prog - found"; \
			found="";					\
		else							\
			${ECHO_MSG} "===>  ${PKGNAME} depends on file: $$prog - not found"; \
		fi;							\
	else								\
		for d in `${ECHO} $$PATH | tr ':' ' '`; do		\
			if [ -x $$d/$$prog ]; then			\
				found="$$d/$$prog";			\
				break;					\
			fi						\
		done;							\
		${ECHO_MSG} "===>  ${PKGNAME} depends on executable: $$prog - $$found found"; \
	fi;								\
	if [ X"$$found" = Xnot ]; then					\
		${ECHO_MSG} "===>  Verifying $$target for $$prog in $$dir"; \
		if [ ! -d "$$dir" ]; then				\
			${ECHO_MSG} ">> No directory for $$prog.  Skipping.."; \
		else							\
			(cd $$dir && ${MAKE} ${.MAKEFLAGS} $$target);	\
			${ECHO_MSG} "===>  Returning to build of ${PKGNAME}"; \
		fi;							\
	fi
.endfor
.endif
.else
	@${DO_NADA}
.endif

fetch-depends:	_DEPENDS_USE
build-depends:	_DEPENDS_USE
run-depends:	_DEPENDS_USE

misc-depends: uptodate-pkgtools
.if defined(DEPENDS)
.if !defined(NO_DEPENDS)
.for dep in ${DEPENDS}
	${_PKG_SILENT}${_PKG_DEBUG}package="`${ECHO} \"${dep}\" | ${SED} -e s/:.\*//`"; \
	dir="`${ECHO} \"${dep}\" | ${SED} -e s/.\*://`";		\
	found="`${PKG_INFO} -e \"$$package\" || ${TRUE}`";		\
	if [ X"$$found" != X"" ]; then					\
		${ECHO_MSG} "===>  ${PKGNAME} depends on installed package: $$package - `${ECHO} $$found | ${SED} -e 's|${PKG_DBDIR}/||g' | tr '\012' '\040'` found"; \
	else								\
		${ECHO_MSG} "===>  ${PKGNAME} depends on package: $$package"; \
		target=${DEPENDS_TARGET};				\
		${ECHO_MSG} "===>  Verifying $$target for $$dir"; 	\
		if [ ! -d $$dir ]; then					\
			${ECHO_MSG} ">> No directory for $$dir.  Skipping.."; \
		else							\
			(cd $$dir && ${MAKE} ${.MAKEFLAGS} $$target);	\
			found="`${PKG_INFO} -e \"$$package\" || ${TRUE}`"; \
			if [ X"$$found" = X"" ]; then		\
				${ECHO_MSG} "===> $$package did not install properly"; \
				exit 1 ; 				\
			fi;						\
		fi							\
	fi							
.endfor
.endif	# !NO_DEPENDS
.else
	@${DO_NADA}
.endif	# DEPENDS

.endif

.if !target(clean-depends)
clean-depends:
.if defined(FETCH_DEPENDS) || defined(BUILD_DEPENDS) \
	|| defined(DEPENDS) || defined(RUN_DEPENDS)
	@for dir in `${ECHO} ${FETCH_DEPENDS} ${BUILD_DEPENDS} ${DEPENDS} ${RUN_DEPENDS} | ${TR} '\040' '\012' | ${SED} -e 's/^[^:]*://' -e 's/:.*//' | sort -u`; do \
		if [ -d $$dir ] ; then					\
			(cd $$dir && ${MAKE} CLEANDEPENDS=${CLEANDEPENDS} clean ); \
		fi							\
	done
.endif
.endif

.if !target(depends-list)
depends-list:
.for dir in ${FETCH_DEPENDS} ${BUILD_DEPENDS} ${DEPENDS}
	@cd ${dir:C/^[^:]*://:C/:.*//} && ${MAKE} package-name depends-list PACKAGE_NAME_TYPE=${PACKAGE_NAME_TYPE}
.endfor
.endif

# If PACKAGES is set to the default (../../pkgsrc/packages), the current
# ${MACHINE_ARCH} and "release" (uname -r) will be used. Otherwise a directory
# structure of ...pkgsrc/packages/`uname -r`/${MACHINE_ARCH} is assumed.
# The PKG_URL is set from FTP_PKG_URL_* or CDROM_PKG_URL_*, depending on
# the target used to generate the README.html file.
.if !target(binpkg-list)

.ifndef OS_VERSION
OS_VERSION!=	/usr/bin/uname -r
.endif

binpkg-list:
	@cd ${PACKAGES};						\
	case `/bin/pwd` in						\
	*/pkgsrc/packages)						\
		if [ -f ${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX} ]; then \
			${ECHO} "<li> ${MACHINE_ARCH} (${OPSYS} <a href=\"${PKG_URL}/${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX}\"> ${OS_VERSION} </a>)"; \
		fi							\
		;;							\
	*)								\
		cd ${PACKAGES}/../..;					\
		for i in [1-9].*/*; do					\
			if [ -f $$i/${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX} ]; then \
				${ECHO} $$i;				\
			fi ;						\
		done | ${AWK} -F/ '					\
			{						\
				release = $$1;				\
				arch = $$2; 				\
				if (arch != "m68k") {			\
					if (arch in urls)		\
						urls[arch] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX}\">" release "</a>, " urls[arch]; \
					else				\
						urls[arch] = "<a href=\"${PKG_URL}/" release "/" arch "/${PKGREPOSITORYSUBDIR}/${PKGNAME}${PKG_SUFX}\">" release "</a> "; \
				}					\
			} 						\
			END { 						\
				for (arch in urls) {			\
					print "<li> " arch " (NetBSD " urls[arch] ")"; \
				}					\
			} '						\
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
# distribution-name|port-path|installation-prefix|comment| \
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
	case "A${FETCH_DEPENDS}B${BUILD_DEPENDS}C${DEPENDS}D" in	\
		ABCD) ;;						\
		*) cd ${.CURDIR} && ${ECHO} -n `${MAKE} depends-list|sort -u`;; \
	esac;								\
	${ECHO} -n "|";							\
	case "A${RUN_DEPENDS}B${DEPENDS}C" in				\
		ABC) ;;							\
		*) cd ${.CURDIR} && ${ECHO} -n "`${MAKE} package-depends PACKAGE_DEPENDS_WITH_PATTERNS=true|sort -u`";; \
	esac;								\
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
	@if [ -f README.html ]; then ${MV} -f README.html README.html.BAK ; fi
	@cd ${.CURDIR} && ${MAKE} README.html PKG_URL=${FTP_PKG_URL_HOST}${FTP_PKG_URL_DIR}
.endif

# This target is used to generate README.html files, very like "readme"
# However, a different target was used for ease of use.
.if !target(cdrom-readme)
CDROM_PKG_URL_HOST?=	file://localhost
CDROM_PKG_URL_DIR?=	/usr/pkgsrc/packages

cdrom-readme:
	@if [ -f README.html ]; then ${MV} -f README.html README.html.BAK ; fi
	@cd ${.CURDIR} && ${MAKE} README.html PKG_URL=${CDROM_PKG_URL_HOST}${CDROM_PKG_URL_DIR}
.endif

.if (${OPSYS} == "NetBSD")
README_NAME=	${TEMPLATES}/README.pkg
.elif (${OPSYS} == "SunOS")
README_NAME=	${TEMPLATES}/README.pkg
.else
README_NAME=	${TEMPLATES}/README.port
.endif

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

README.html:
	@${MAKE} depends-list PACKAGE_NAME_TYPE=html | sort -u >> $@.tmp1
	@[ -s $@.tmp1 ] || ${ECHO} "<I>(none)</I>" >> $@.tmp1
	@${MAKE} package-depends PACKAGE_NAME_TYPE=html | sort -u >> $@.tmp2
	@[ -s $@.tmp2 ] || ${ECHO} "<I>(none)</I>" >> $@.tmp2
	@${ECHO} ${PKGNAME} | ${HTMLIFY} >> $@.tmp3
	@${MAKE} binpkg-list  >> $@.tmp4
	@[ -s $@.tmp4 ] || ${ECHO} "<I>(no precompiled binaries available)</I>" >> $@.tmp4
	@${SED} -e 's|%%PORT%%|'"`${MAKE} package-path | ${HTMLIFY}`"'|g' \
		-e '/%%PKG%%/r$@.tmp3'					\
		-e '/%%PKG%%/d'						\
		${SED_LICENSE_EXPR}					\
		${SED_HOMEPAGE_EXPR}					\
		-e '/%%COMMENT%%/r${PKGDIR}/COMMENT'			\
		-e '/%%COMMENT%%/d'					\
		-e '/%%BUILD_DEPENDS%%/r$@.tmp1'			\
		-e '/%%BUILD_DEPENDS%%/d'				\
		-e '/%%RUN_DEPENDS%%/r$@.tmp2'				\
		-e '/%%RUN_DEPENDS%%/d'					\
		-e '/%%BIN_PKGS%%/r$@.tmp4'				\
		-e '/%%BIN_PKGS%%/d'					\
		${README_NAME} >> $@.tmp
	@if cmp -s $@.tmp $@.BAK; then					\
		${MV} $@.BAK $@;					\
		${RM} $@.tmp;						\
	else								\
		${ECHO_MSG} "===>  Creating README.html for ${_THISDIR_}${PKGNAME}"; \
		${MV} $@.tmp $@;					\
		${RM} -f $@.BAK;					\
	fi
	@${RM} -f $@.tmp1 $@.tmp2 $@.tmp3 $@.tmp4 $@.tmp5

.if !target(show-pkgtools-version)
show-pkgtools-version:
	@${IDENT} ${PKG_CREATE} ${PKG_DELETE} ${PKG_INFO} ${PKG_ADD} | ${AWK} '$$1 ~ /\$$NetBSD/ && $$2 !~ /^crt0/ { gsub("/", "", $$4); print $$4 }' | sort | ${TAIL} -n 1
.endif

.if !target(print-depends-list)
print-depends-list:
.if defined(FETCH_DEPENDS) || defined(BUILD_DEPENDS) || defined(DEPENDS)
	@${ECHO} -n 'This port requires package(s) "'
	@${ECHO} -n `${MAKE} depends-list | sort -u`
	@${ECHO} '" to build.'
.endif
.endif

.if !target(print-package-depends)
print-package-depends:
.if defined(RUN_DEPENDS) || defined(DEPENDS)
	@${ECHO} -n 'This port requires package(s) "'
	@${ECHO} -n "`${MAKE} package-depends | sort -u`"
	@${ECHO} '" to run.'
.endif
.endif

# Fake installation of package so that user can pkg_delete it later.
# Also, make sure that an installed port is recognized correctly in
# accordance to the @pkgdep directive in the packing lists

.if !target(fake-pkg)
fake-pkg: ${PLIST} ${DESCR}
	${_PKG_SILENT}${_PKG_DEBUG}if [ ! -f ${PLIST} -o ! -f ${COMMENT} -o ! -f ${DESCR} ]; then \
		${ECHO} "** Missing package files for ${PKGNAME} - installation not recorded."; \
		exit 1;							\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}if [ ! -d ${PKG_DBDIR} ]; then	\
		${RM} -f ${PKG_DBDIR};					\
		${MKDIR} ${PKG_DBDIR};					\
	fi
.if defined(FORCE_PKG_REGISTER)
	${_PKG_SILENT}${_PKG_DEBUG}					\
	pkgtools_version=`${MAKE} show-pkgtools-version`;		\
	if [ $$pkgtools_version -gt ${PKGTOOLS_PKGDB_VERSION} ]; then	\
		${PKG_DELETE} -O ${PKGNAME};				\
	fi
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -rf ${PKG_DBDIR}/${PKGNAME}
.endif
	${_PKG_SILENT}${_PKG_DEBUG}${RM} -f ${BUILD_VERSION_FILE} ${BUILD_INFO_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}files="";				\
	for f in ${.CURDIR}/Makefile ${FILESDIR}/* ${PKGDIR}/*; do	\
		if [ -f $$f ]; then					\
			files="$$files $$f";				\
		fi;							\
	done;								\
	if [ -d ${PATCHDIR} ]; then					\
		for f in ${PATCHDIR}/patch-*; do			\
			case $$f in					\
			*.orig|*.rej|*~) ;;				\
			*)						\
				files="$$files $$f" ;;			\
			esac;						\
		done;							\
	fi;								\
	pkgsrcdir=`(cd ../.. && /bin/pwd)`;				\
	${GREP} '\$$NetBSD' $$files | ${SED} -e 's|^'$$pkgsrcdir'/||' > ${BUILD_VERSION_FILE};
.for def in ${BUILD_DEFS}
	@${ECHO} "${def}=	${${def}}" | ${SED} -e 's|PATH=[^ 	]*|PATH=...|' >> ${BUILD_INFO_FILE}
.endfor
	@${ECHO} "CC=	${CC}-`${CC} --version`" >> ${BUILD_INFO_FILE}
.ifdef USE_PERL5
	@${ECHO} "PERL=	`${LOCALBASE}/bin/perl --version | ${GREP} version`" >> ${BUILD_INFO_FILE}
.endif
.ifdef USE_GMAKE
	@${ECHO} "GMAKE=	`${GMAKE} --version | ${GREP} version`" >> ${BUILD_INFO_FILE}
.endif
	@${ECHO} "_PKGTOOLS_VER= `${MAKE} show-pkgtools-version`" >> ${BUILD_INFO_FILE}
	${_PKG_SILENT}${_PKG_DEBUG}if [ ! -d ${PKG_DBDIR}/${PKGNAME} ]; then			\
		${ECHO_MSG} "===>  Registering installation for ${PKGNAME}"; \
		${MKDIR} ${PKG_DBDIR}/${PKGNAME};			\
		${PKG_CREATE} ${PKG_ARGS} -O ${PKGFILE} > ${PKG_DBDIR}/${PKGNAME}/+CONTENTS; \
		${CP} ${DESCR} ${PKG_DBDIR}/${PKGNAME}/+DESC;		\
		${CP} ${COMMENT} ${PKG_DBDIR}/${PKGNAME}/+COMMENT;	\
		${CP} ${BUILD_VERSION_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_VERSION; \
		${CP} ${BUILD_INFO_FILE} ${PKG_DBDIR}/${PKGNAME}/+BUILD_INFO; \
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
		for dep in `${MAKE} package-depends PACKAGE_DEPENDS_WITH_PATTERNS=true ECHO_MSG=${TRUE} | sort -u`; do \
			realdep="`${PKG_INFO} -e \"$$dep\" || ${TRUE}`" ; \
			${ECHO} "a sanity check should be put in here to prevent some user having the pkg installed/registered twice somehow - HF" >/dev/null ; \
			if [ -z $$realdep ]; then			\
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

# Depend is generally meaningless for arbitrary ports, but if someone wants
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

# generate ${PLIST} from ${PLIST_SRC} by:
# - fixing list of man-pages according to MANCOMPRESSED/MANZ
#   (we don't take any notice of MANCOMPRESSED as many packages have .gz
#   pages in PLIST even when they install manpages without compressing them)
# - substituting ${OPSYS}, ${MACHINE_ARCH} and ${MACHINE_GNU_ARCH}

.if ${OPSYS} == "NetBSD"
IMAKE_MAN_CMD=
.ifdef MANZ
MANZ_EXPRESSION= -e 's|\(^\([^/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]$$\)|\1.gz|' \
		-e 's|\(^\([^/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*[0-9ln]$$\)|\1.gz|'
.else
MANZ_EXPRESSION= -e 's|\(^\([^/]*/\)*man/\([^/]*/\)\{0,1\}man[1-9ln]/.*[1-9ln]\)\.gz$$|\1|' \
		-e 's|\(^\([^/]*/\)*man/\([^/]*/\)\{0,1\}cat[1-9ln]/.*[0-9ln]\)\.gz$$|\1|'
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
				-e 's|\$${OPSYS}|${OPSYS}|g'		\
				-e 's|\$${OS_VERSION}|${OS_VERSION}|g'	\
				-e 's|\$${MACHINE_ARCH}|${MACHINE_ARCH}|g' \
				-e 's|\$${MACHINE_GNU_ARCH}|${MACHINE_GNU_ARCH}|g' \
				-e 's|\$${LOWER_OPSYS}|${LOWER_OPSYS}|g'\
			> ${PLIST}; 					\
	fi

# generate ${DESCR} from ${DESCR_SRC} by:
# - Appending the homepage URL, if any

${DESCR}: ${DESCR_SRC}
	@${CAT} ${DESCR_SRC} > ${DESCR}
.if defined(HOMEPAGE)
	@(${ECHO} ; ${ECHO} "Homepage:" ; \
	${ECHO} '${HOMEPAGE}') >> ${DESCR}	
.endif
