# $NetBSD: buildlink.mk,v 1.1 2001/06/30 11:26:32 zuntum Exp $
#
# This Makefile fragment is included by packages that use ClanLib.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define BUILDLINK_DEPENDS.ClanLib to the dependency pattern
#     for the version of ClanLib desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Add ${BUILDLINK_DIR}/include to the front of the C preprocessor's header
#     search path, and
# (4) Add ${BUILDLINK_DIR}/lib to the front of the linker's library search
#     path.

.if !defined(CLANLIB_BUILDLINK_MK)
CLANLIB_BUILDLINK_MK=	# defined

BUILDLINK_DEPENDS.ClanLib?=	ClanLib>=0.4.4
DEPENDS+=	${BUILDLINK_DEPENDS.ClanLib}:../../graphics/clanlib

BUILDLINK_PREFIX.ClanLib=	${X11BASE}
BUILDLINK_FILES.ClanLib=	lib/libclancore.*
BUILDLINK_FILES.ClanLib+=	lib/ClanLib/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/*.h
BUILDLINK_FILES.ClanLib+=	include/ClanLib/Core/*/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/GL/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/GUI/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/Lua/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/MIDI/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/MPEG/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/Magick/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/MikMod/*
BUILDLINK_FILES.ClanLib+=	include/ClanLib/png/*

.include "../../graphics/hermes/buildlink.mk"
.include "../../graphics/png/buildlink.mk"
.include "../../graphics/Mesa/buildlink.mk"
.include "../../devel/pth/buildlink.mk"

BUILDLINK_TARGETS.ClanLib=	ClanLib-buildlink
BUILDLINK_TARGETS.ClanLib+=	ClanLib-buildlink-config-wrapper
BUILDLINK_TARGETS+=	${BUILDLINK_TARGETS.ClanLib}

BUILDLINK_CONFIG.ClanLib=	${LOCALBASE}/bin/clanlib-config
BUILDLINK_CONFIG_WRAPPER.ClanLib=${BUILDLINK_DIR}/bin/clanlib-config

.if defined(USE_CONFIG_WRAPPER) && defined(GNU_CONFIGURE)
CONFIGURE_ENV+=			CLANLIB_CONFIG="${BUILDLINK_CONFIG_WRAPPER.ClanLib}"
.endif

pre-configure: ${BUILDLINK_TARGETS.ClanLib}
ClanLib-buildlink: _BUILDLINK_USE
ClanLib-buildlink-config-wrapper: _BUILDLINK_CONFIG_WRAPPER_USE

.include "../../mk/bsd.buildlink.mk"

.endif	# CLANLIB_BUILDLINK_MK
