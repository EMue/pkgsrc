# $NetBSD: bsd.prefs.mk,v 1.15 2000/02/13 10:33:22 tron Exp $
#
# Make file, included to get the site preferences, if any.  Should
# only be included by package Makefiles before any .if defined()
# statements or modifications to "passed" variables (CFLAGS, LDFLAGS, ...),
# to make sure any variables defined in /etc/mk.conf, $MAKECONF, or
# the system defaults (sys.mk and bsd.own.mk) are used.

# Do not recursively include mk.conf, redefine OPSYS, include bsd.own.mk, etc.
.ifndef BSD_PKG_MK

# Let mk.conf know that this is pkgsrc.
BSD_PKG_MK=1 
__PREFIX_SET__:=${PREFIX}

.if exists(/usr/bin/uname)
UNAME=/usr/bin/uname
.elif exists(/bin/uname)
UNAME=/bin/uname
.else
UNAME=echo Unknown
.endif

.ifndef OPSYS
OPSYS!=			${UNAME} -s
.endif
.ifndef OS_VERSION
OS_VERSION!=		${UNAME} -r
.endif

# Preload these for architectures not in all variations of bsd.own.mk.
GNU_ARCH.alpha?=	alpha
GNU_ARCH.arm32?=	arm
GNU_ARCH.i386?=		i386
GNU_ARCH.i486?=		i386
GNU_ARCH.i586?=		i386
GNU_ARCH.i686?=		i386
GNU_ARCH.m68k?=		m68k
GNU_ARCH.mips?=		mipsel
GNU_ARCH.ns32k?=	ns32k
GNU_ARCH.sparc?=	sparc
GNU_ARCH.vax?=		vax
MACHINE_GNU_ARCH?=	${GNU_ARCH.${MACHINE_ARCH}}

.if ${OPSYS} == "NetBSD"
LOWER_OPSYS?=		netbsd
.elif ${OPSYS} == "SunOS"
.if ${MACHINE_ARCH} == "unknown"
LOWER_ARCH!=		${UNAME} -p
.endif
LOWER_VENDOR?=		sun
LOWER_OPSYS?=		solaris
.elif ${OPSYS} == "Linux"
LOWER_OPSYS?=		linux
.if ${MACHINE_ARCH} == "unknown"
LOWER_ARCH!=		${UNAME} -m | sed -e 's/[456]86/386/'
.if ${LOWER_ARCH} == "i386"
LOWER_VENDOR?=		pc
.else
LOWER_VENDOR?=		unknown
.endif
.endif

.elif !defined(LOWER_OPSYS)
LOWER_OPSYS!=		echo ${OPSYS} | tr A-Z a-z
.endif

LOWER_VENDOR?=
LOWER_ARCH?=		${MACHINE_GNU_ARCH}

MACHINE_PLATFORM?=	${OPSYS}-${OS_VERSION}-${MACHINE_ARCH}
MACHINE_GNU_PLATFORM?=	${LOWER_ARCH}-${LOWER_VENDOR}-${LOWER_OPSYS}

# Needed on NetBSD and SunOS (zoularis) to prevent an "install:" target
# from being created in bsd.own.mk.
NEED_OWN_INSTALL_TARGET=no

.include <bsd.own.mk>

.if (${OPSYS} == "NetBSD") || (${OPSYS} == "SunOS") || (${OPSYS} == "Linux")
SHAREOWN?=		${DOCOWN}
SHAREGRP?=		${DOCGRP}
SHAREMODE?=		${DOCMODE}
.elif (${OPSYS} == "OpenBSD")
MAKE_ENV+=		EXTRA_SYS_MK_INCLUDES="<bsd.own.mk>"
.endif

.if defined(PREFIX) && (${PREFIX} != ${__PREFIX_SET__})
.BEGIN:
	@${ECHO_MSG} "You can NOT set PREFIX manually or in mk.conf.  Set LOCALBASE or X11BASE"
	@${ECHO_MSG} "depending on your needs.  See the pkg system documentation for more info."
	@${FALSE}
.endif

# if the system is IPv6-ready NetBSD, compile with IPv6 support turned on.
.if (${OPSYS} == "NetBSD") && !defined(USE_SOCKS) && \
    exists(/usr/include/netinet6)
USE_INET6?=		YES
.endif

# Preload all default values for CFLAGS, LDFLAGS, etc. before bsd.pkg.mk
# or a pkg Makefile modifies them.
.include <sys.mk>

.endif
