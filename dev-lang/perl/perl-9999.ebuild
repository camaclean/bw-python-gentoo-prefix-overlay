# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/perl/perl-5.22.0.ebuild,v 1.3 2015/06/16 13:20:30 dilfridge Exp $

EAPI=5

inherit hostsym

PATCH_VER=1

SHORT_PV="${PV%.*}"
MY_P="perl-${PV/_rc/-RC}"
MY_PV="${PV%_rc*}"

DESCRIPTION="Larry Wall's Practical Extraction and Report Language"

HOMEPAGE="http://www.perl.org/"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0/${SHORT_PV}"
KEYWORDS="~alpha ~amd64 ~amd64-fbsd ~amd64-linux ~arm ~arm64 ~hppa ~hppa-hpux ~ia64 ~ia64-hpux ~ia64-linux ~m68k ~m68k-mint ~mips ~ppc ~ppc64 ~ppc-aix ~ppc-macos ~s390 ~sh ~sparc ~sparc64-solaris ~sparc-solaris ~x64-freebsd ~x64-macos ~x64-solaris ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~x86-linux ~x86-macos ~x86-solaris"
IUSE="berkdb debug doc gdbm ithreads"

RDEPEND="
	berkdb? ( sys-libs/db:* )
	gdbm? ( >=sys-libs/gdbm-1.8.3 )
	app-arch/bzip2
	sys-libs/zlib
"
DEPEND="${RDEPEND}
	!prefix? ( elibc_FreeBSD? ( sys-freebsd/freebsd-mk-defs ) )
"
PDEPEND="
	>=app-admin/perl-cleaner-2.5
	>=virtual/perl-File-Temp-0.230.400-r2
	>=virtual/perl-Data-Dumper-2.154.0
"
# bug 390719, bug 523624

S="${WORKDIR}"

src_install() {
	dohostsyms /usr/bin/perl
}

