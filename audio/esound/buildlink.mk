# $NetBSD: buildlink.mk,v 1.2 2001/06/23 19:26:49 jlam Exp $
#
# This Makefile fragment is included by packages that use esound.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.esound to the dependency pattern
#     for the version of esound desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(ESOUND_BUILDLINK_MK)
ESOUND_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.esound?=	esound>=0.2.18
DEPENDS+=			${BUILDLINK_DEPENDS.esound}:../../audio/esound

BUILDLINK_PREFIX.esound=	${LOCALBASE}
BUILDLINK_FILES.esound=		include/esd.h
BUILDLINK_FILES.esound+=	lib/libesd.*

.include "../../audio/libaudiofile/buildlink.mk"

BUILDLINK_TARGETS.esound=	esound-buildlink
BUILDLINK_TARGETS.esound+=	esound-buildlink-config-wrapper
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.esound}

BUILDLINK_CONFIG.esound=		${LOCALBASE}/bin/esd-config
BUILDLINK_CONFIG_WRAPPER.esound=	${BUILDLINK_DIR}/bin/esd-config

.if defined(USE_CONFIG_WRAPPER) && defined(GNU_CONFIGURE)
CONFIGURE_ENV+=		ESD_CONFIG="${BUILDLINK_CONFIG_WRAPPER.esound}"
.endif

pre-configure: ${BUILDLINK_TARGETS.esound}
esound-buildlink: _BUILDLINK_USE
esound-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# ESOUND_BUILDLINK_MK
