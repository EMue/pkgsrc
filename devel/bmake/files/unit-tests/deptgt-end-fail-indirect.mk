# $NetBSD: deptgt-end-fail-indirect.mk,v 1.2 2024/09/17 11:52:30 jperkin Exp $
#
# Tests for an error in a dependency of the .END node.
#
# Before 2020-11-25, an error in the .END target did not print the "Stop."
# and exited with status 0.  The cause for this was a missing condition in
# Compat_MakeAll in the handling of the .END node.

all:
	: $@

.END: failing
	: Making ${.TARGET} from ${.ALLSRC}.

failing: .PHONY
	false
