# $NetBSD: buildlink3.mk,v 1.13 2024/08/09 09:42:23 ryoon Exp $

BUILDLINK_TREE+=	notmuch

.if !defined(NOTMUCH_BUILDLINK3_MK)
NOTMUCH_BUILDLINK3_MK:=

BUILDLINK_API_DEPENDS.notmuch+=	notmuch>=0.16
BUILDLINK_ABI_DEPENDS.notmuch+=	notmuch>=0.38.3nb1
BUILDLINK_PKGSRCDIR.notmuch?=	../../mail/notmuch

.include "../../mail/gmime3/buildlink3.mk"
.include "../../textproc/xapian/buildlink3.mk"
.endif	# NOTMUCH_BUILDLINK3_MK

BUILDLINK_TREE+=	-notmuch
