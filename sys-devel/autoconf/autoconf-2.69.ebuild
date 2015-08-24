# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf/autoconf-2.69.ebuild,v 1.18 2014/01/17 04:23:13 vapier Exp $

EAPI="3"

inherit eutils hostsym

SRC_URI=""

DESCRIPTION="Used to create autoconfiguration files"
HOMEPAGE="http://www.gnu.org/software/autoconf/autoconf.html"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

LICENSE="GPL-3"
SLOT=$(usex multislot "${PV}" "2.5")
IUSE="emacs multislot"

DEPEND=">=sys-devel/m4-1.4.16
	>=dev-lang/perl-5.6"
RDEPEND="${DEPEND}
	>=sys-devel/autoconf-wrapper-13"
PDEPEND="emacs? ( app-emacs/autoconf-mode )"

S=${WORKDIR}

src_install() {
	dohostsyms /usr/bin/autoconf-${PV} \
		/usr/bin/autoheader-${PV} \
		/usr/bin/autom4te-${PV} \
		/usr/bin/autoreconf-${PV} \
		/usr/bin/autoscan-${PV} \
		/usr/bin/autoupdate-${PV} \
		/usr/bin/ifnames-${PV}
	dohostdirsym /usr/share/autoconf-${PV}
}
