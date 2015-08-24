# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/sed/sed-9999.ebuild,v 1.5 2014/02/08 13:24:00 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs hostsym

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="http://sed.sourceforge.net/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl nls selinux static"

RDEPEND="acl? ( virtual/acl )
	nls? ( virtual/libintl )
	selinux? ( sys-libs/libselinux )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	mkdir -p $S
}

src_install() {
	dohostsyms /bin/sed
}
