# $NetBSD: buildlink.mk,v 1.1 2001/06/26 00:37:26 zuntum Exp $
#
# This Makefile fragment is included by packages that use libproplist.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.libproplist to the dependency pattern
#     for the version of libproplist desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(LIBPROPLIST_BUILDLINK_MK)
LIBPROPLIST_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.libproplist?=	libproplist>=0.10.1
DEPENDS+=	${BUILDLINK_DEPENDS.libproplist}:../../databases/libproplist

BUILDLINK_PREFIX.libproplist=	${LOCALBASE}
BUILDLINK_FILES.libproplist=	include/proplist.h
BUILDLINK_FILES.libproplist+=	lib/libPropList.*

BUILDLINK_TARGETS.libproplist=	libproplist-buildlink
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.libproplist}

pre-configure: ${BUILDLINK_TARGETS.libproplist}
libproplist-buildlink: _BUILDLINK_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# LIBPROPLIST_BUILDLINK_MK
