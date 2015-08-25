# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/make/make-4.1-r1.ebuild,v 1.11 2015/04/04 22:26:05 vapier Exp $

EAPI=4

inherit flag-o-matic eutils hostsym

DESCRIPTION="Standard tool to compile source trees"
HOMEPAGE="http://www.gnu.org/software/make/make.html"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="guile nls static"

CDEPEND="guile? ( >=dev-scheme/guile-1.8 )"
DEPEND="${CDEPEND}
	nls? ( sys-devel/gettext )"
RDEPEND="${CDEPEND}
	nls? ( virtual/libintl )"

S=${WORKDIR}

src_install() {
	dohostsyms /usr/bin/gmake /usr/bin/make
}
