# $NetBSD: buildlink.mk,v 1.2 2001/06/28 21:53:39 jlam Exp $
#
# This Makefile fragment is included by packages that use smpeg.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.smpeg to the dependency pattern
#     for the version of smpeg desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(SMPEG_BUILDLINK_MK)
SMPEG_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.smpeg?=	smpeg>=0.4.1
DEPENDS+=	${BUILDLINK_DEPENDS.smpeg}:../../devel/smpeg

BUILDLINK_PREFIX.smpeg=		${LOCALBASE}
BUILDLINK_FILES.smpeg=		include/smpeg/*
BUILDLINK_FILES.smpeg+=		lib/libsmpeg-*
BUILDLINK_FILES.smpeg+=		lib/libsmpeg.*

.include "../../devel/SDL/buildlink.mk"

BUILDLINK_TARGETS.smpeg=	smpeg-buildlink
BUILDLINK_TARGETS.smpeg+=	smpeg-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.smpeg}

BUILDLINK_CONFIG.smpeg=		${LOCALBASE}/bin/smpeg-config
BUILDLINK_CONFIG_WRAPPER.smpeg=	${BUILDLINK_DIR}/bin/smpeg-config

.if defined(USE_CONFIG_WRAPPER) && defined(GNU_CONFIGURE)
CONFIGURE_ENV+=		SMPEG_CONFIG="${BUILDLINK_CONFIG_WRAPPER.smpeg}"
.endif

pre-configure: ${BUILDLINK_TARGETS.smpeg}
smpeg-buildlink: _BUILDLINK_USE
smpeg-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# SMPEG_BUILDLINK_MK
