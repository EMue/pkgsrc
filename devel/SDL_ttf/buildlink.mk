# $NetBSD: buildlink.mk,v 1.1 2001/06/26 09:54:07 zuntum Exp $
#
# This Makefile fragment is included by packages that use SDL_ttf.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.SDL_ttf to the dependency pattern
#     for the version of SDL_ttf desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(SDL_ttf_BUILDLINK_MK)
SDL_ttf_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.SDL_ttf?=	SDL_ttf>=1.2.2
DEPENDS+=	${BUILDLINK_DEPENDS.SDL_ttf}:../../devel/SDL_ttf

BUILDLINK_PREFIX.SDL_ttf=	${LOCALBASE}
BUILDLINK_FILES.SDL_ttf=	include/SDL/SDL_ttf.h
BUILDLINK_FILES.SDL_ttf+=	lib/libSDL_ttf.*

.include "../../devel/SDL/buildlink.mk"

BUILDLINK_TARGETS.SDL_ttf=	SDL_ttf-buildlink
BUILDLINK_TARGETS+=		${BUILDLINK_TARGETS.SDL_ttf}

pre-configure: ${BUILDLINK_TARGETS.SDL_ttf}
SDL_ttf-buildlink: _BUILDLINK_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# SDL_ttf_BUILDLINK_MK
