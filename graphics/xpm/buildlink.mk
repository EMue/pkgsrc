# $NetBSD: buildlink.mk,v 1.3 2001/07/01 22:59:26 jlam Exp $
#
# This Makefile fragment is included by packages that use xpm.
#
# To use this Makefile fragment, simply:
#
# (1) Include this Makefile fragment in the package Makefile,
# (2) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (3) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(XPM_BUILDLINK_MK)
XPM_BUILDLINK_MK=	# defined

.include "../../mk/bsd.buildlink.mk"

USE_XPM=		# defined

# We double-list because we're not sure if the files are in ${X11BASE}
# or in ${LOCALBASE}.

BUILDLINK_PREFIX.xpm-x11base=	${X11BASE}
BUILDLINK_FILES.xpm-x11base=	include/X11/X11/xpm.h	# for OpenWindows
BUILDLINK_FILES.xpm-x11base+=	include/X11/xpm.h
BUILDLINK_FILES.xpm-x11base+=	lib/libXpm.*

BUILDLINK_TARGETS.xpm=		xpm-x11base-buildlink

BUILDLINK_PREFIX.xpm-localbase=	${LOCALBASE}
BUILDLINK_FILES.xpm-localbase=	include/X11/X11/xpm.h	# for OpenWindows
BUILDLINK_FILES.xpm-localbase+=	include/X11/xpm.h
BUILDLINK_FILES.xpm-localbase+=	lib/libXpm.*

BUILDLINK_TARGETS.xpm+=		xpm-localbase-buildlink

BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.xpm}

pre-configure: ${BUILDLINK_TARGETS.xpm}
xpm-x11base-buildlink: _BUILDLINK_USE
xpm-localbase-buildlink: _BUILDLINK_USE

.endif	# XPM_BUILDLINK_MK
