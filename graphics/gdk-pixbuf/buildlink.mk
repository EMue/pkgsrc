# $NetBSD: buildlink.mk,v 1.2 2001/06/16 19:53:09 jlam Exp $
#
# This Makefile fragment is included by packages that use gdk-pixbuf.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define GDK_PIXBUF_REQD to the version of gdk-pixbuf desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(GDK_PIXBUF_BUILDLINK_MK)
GDK_PIXBUF_BUILDLINK_MK=	# defined

GDK_PIXBUF_REQD?=	0.8.0nb1
DEPENDS+=		gdk-pixbuf>=${GDK_PIXBUF_REQD}:../../graphics/gdk-pixbuf

BUILDLINK_PREFIX.gdk-pixbuf=	${X11PREFIX}
BUILDLINK_FILES.gdk-pixbuf=	include/gdk-pixbuf/*
BUILDLINK_FILES.gdk-pixbuf+=	lib/libgdk_pixbuf.*
BUILDLINK_FILES.gdk-pixbuf+=	lib/libgdk_pixbuf_xlib.*

.include "../../graphics/jpeg/buildlink.mk"
.include "../../graphics/png/buildlink.mk"
.include "../../graphics/tiff/buildlink.mk"

BUILDLINK_TARGETS.gdk-pixbuf=	gdk-pixbuf-buildlink
BUILDLINK_TARGETS.gdk-pixbuf+=	gdk-pixbuf-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.gdk-pixbuf}

BUILDLINK_CONFIG.gdk-pixbuf=		${X11PREFIX}/bin/gdk-pixbuf-config
BUILDLINK_CONFIG_WRAPPER.gdk-pixbuf=	${BUILDLINK_DIR}/bin/gdk-pixbuf-config

.if defined(USE_CONFIG_WRAPPER) && defined(GNU_CONFIGURE)
CONFIGURE_ENV+=	GDK_PIXBUF_CONFIG="${BUILDLINK_CONFIG_WRAPPER.gdk-pixbuf}"
.endif

pre-configure: ${BUILDLINK_TARGETS.gdk-pixbuf}
gdk-pixbuf-buildlink: _BUILDLINK_USE
gdk-pixbuf-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# GDK_PIXBUF_BUILDLINK_MK
