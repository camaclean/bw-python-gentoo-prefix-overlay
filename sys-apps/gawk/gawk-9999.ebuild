# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/gawk-4.1.3.ebuild,v 1.1 2015/05/23 19:38:43 polynomial-c Exp $

EAPI="4"

inherit eutils hostsym

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="http://www.gnu.org/software/gawk/gawk.html"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="mpfr nls readline"

RDEPEND="mpfr? ( dev-libs/mpfr )
	readline? ( sys-libs/readline )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

S=${WORKDIR}

src_install() {
	dohostsyms /usr/bin/gawk /usr/bin/pgawk /usr/bin/awk
	dohostoptsyms /usr/bin/dgawk /usr/bin/igawk
}
