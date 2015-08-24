# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/xz-utils/xz-utils-5.2.1-r1.ebuild,v 1.1 2015/06/03 02:34:55 mgorny Exp $

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

EAPI="4"

inherit eutils toolchain-funcs hostsym

MY_P="${PN/-utils}-${PV/_}"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
S=${WORKDIR}/${MY_P}
EXTRA_DEPEND=

DESCRIPTION="utils for managing LZMA compressed files"
HOMEPAGE="http://tukaani.org/xz/"

# See top-level COPYING file as it outlines the various pieces and their licenses.
LICENSE="public-domain LGPL-2.1+ GPL-2+"
SLOT="0"
IUSE="elibc_FreeBSD nls static-libs +threads"

RDEPEND="!<app-arch/lzma-4.63
	!app-arch/lzma-utils
	!<app-arch/p7zip-4.57"
DEPEND="${RDEPEND}
	${EXTRA_DEPEND}"

src_unpack() {
	mkdir -p $S
}

src_install() {
	dohostsyms /usr/bin/lzmadec /usr/bin/lzmainfo /usr/bin/xz /usr/bin/xzdec /usr/bin/xzdiff \
		/usr/bin/xzgrep /usr/bin/xzless /usr/bin/xzmore /usr/bin/lzcat /usr/bin/lzcmp \
		/usr/bin/lzdiff /usr/bin/lzegrep /usr/bin/lzfgrep /usr/bin/lzgrep /usr/bin/lzless \
		/usr/bin/lzma /usr/bin/lzmore /usr/bin/unlzma /usr/bin/unxz /usr/bin/xzcat /usr/bin/xzcmp \
		/usr/bin/xzegrep /usr/bin/xzfgrep
}
