# $NetBSD: buildlink.mk,v 1.2 2001/06/10 00:09:30 jlam Exp $
#
# This Makefile fragment is included by packages that use gmp.
#
# To use this Makefile fragment, simply:
#
# (1) Optionally define GMP_REQD to the version of gmp desired.
# (2) Include this Makefile fragment in the package Makefile,
# (3) Optionally define BUILDLINK_INCDIR and BUILDLINK_LIBDIR,
# (4) Add ${BUILDLINK_INCDIR} to the front of the C preprocessor's header
#     search path, and
# (5) Add ${BUILDLINK_LIBDIR} to the front of the linker's library search
#     path.

.if !defined(GMP_BUILDLINK_MK)
GMP_BUILDLINK_MK=	# defined

GMP_REQD?=		3.0
DEPENDS+=		gmp>=${GMP_REQD}:../../devel/gmp

GMP_HEADERS=		${LOCALBASE}/include/gmp.h
GMP_LIBS=		${LOCALBASE}/lib/libgmp.*

BUILDLINK_INCDIR?=	${WRKDIR}/include
BUILDLINK_LIBDIR?=	${WRKDIR}/lib

GMP_BUILDLINK_COOKIE=		${WRKDIR}/.gmp_buildlink_done
GMP_BUILDLINK_TARGETS=		link-gmp-headers
GMP_BUILDLINK_TARGETS+=		link-gmp-libs
BUILDLINK_TARGETS+=		${GMP_BUILDLINK_COOKIE}

pre-configure: ${GMP_BUILDLINK_COOKIE}

${GMP_BUILDLINK_COOKIE}: ${GMP_BUILDLINK_TARGETS}
	@${TOUCH} ${TOUCH_FLAGS} ${GMP_BUILDLINK_COOKIE}

# This target links the headers into ${BUILDLINK_INCDIR}, which should
# be searched first by the C preprocessor.
#
link-gmp-headers:
	@${ECHO} "Linking gmp headers into ${BUILDLINK_INCDIR}."
	@${MKDIR} ${BUILDLINK_INCDIR}
	@for inc in ${GMP_HEADERS}; do					\
		dest=${BUILDLINK_INCDIR}/`${BASENAME} $${inc}`;		\
		if [ -f $${inc} ]; then					\
			${RM} -f $${dest};				\
			${LN} -sf $${inc} $${dest};			\
		fi;							\
        done

# This target links the libraries into ${BUILDLINK_LIBDIR}, which should
# be searched first by the linker.
#
link-gmp-libs:
	@${ECHO} "Linking gmp libraries into ${BUILDLINK_LIBDIR}."
	@${MKDIR} ${BUILDLINK_LIBDIR}
	@for lib in ${GMP_LIBS}; do					\
		dest=${BUILDLINK_LIBDIR}/`${BASENAME} $${lib}`;		\
		if [ -f $${lib} ]; then					\
			${RM} -f $${dest};				\
			${LN} -sf $${lib} $${dest};			\
		fi;							\
	done

.endif	# GMP_BUILDLINK_MK
