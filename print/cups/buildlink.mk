# $NetBSD: buildlink.mk,v 1.7 2001/06/23 19:26:59 jlam Exp $
#
# This Makefile fragment is included by packages that use libcups.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.cups to the dependency pattern
#     for the version of cups desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(CUPS_BUILDLINK_MK)
CUPS_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.cups?=	cups>=1.1.1
DEPENDS+=	${BUILDLINK_DEPENDS.cups}:../../print/cups

BUILDLINK_PREFIX.cups=	${LOCALBASE}
BUILDLINK_FILES.cups=	include/cups/*
BUILDLINK_FILES.cups+=	lib/libcups.*
BUILDLINK_FILES.cups+=	lib/libcupsimage.*

BUILDLINK_TARGETS.cups=	cups-buildlink
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.cups}

pre-configure: ${BUILDLINK_TARGETS.cups}
cups-buildlink: _BUILDLINK_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# CUPS_BUILDLINK_MK
