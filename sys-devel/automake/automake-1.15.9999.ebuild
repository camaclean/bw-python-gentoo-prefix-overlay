# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake/automake-1.14.1.ebuild,v 1.3 2014/01/17 04:23:15 vapier Exp $

inherit eutils versionator unpacker hostsym

DESCRIPTION="Used to generate Makefile.in from Makefile.am"
HOMEPAGE="http://www.gnu.org/software/automake/"

LICENSE="GPL-2"
# Use Gentoo versioning for slotting.
SLOT="${PV:0:4}"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="dev-lang/perl
	>=sys-devel/automake-wrapper-9
	>=sys-devel/autoconf-2.62
	sys-devel/gnuconfig"
DEPEND="${RDEPEND}
	sys-apps/help2man"

S="${WORKDIR}"

src_install() {
	dohostsyms /usr/bin/automake-${PV:0:4} /usr/bin/aclocal-${PV:0:4}
	dohostdirsym /usr/share/automake-${PV:0:4}
	dohostdirsym /usr/share/aclocal-${PV:0:4}
}
