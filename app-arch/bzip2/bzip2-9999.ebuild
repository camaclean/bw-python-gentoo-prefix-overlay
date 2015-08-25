# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/bzip2/bzip2-1.0.6-r7.ebuild,v 1.2 2014/04/28 17:18:31 mgorny Exp $

# XXX: atm, libbz2.a is always PIC :(, so it is always built quickly
#      (since we're building shared libs) ...

EAPI=4

inherit eutils toolchain-funcs multilib multilib-minimal prefix hostsym

DESCRIPTION="A high-quality data compressor used extensively by Gentoo Linux"
HOMEPAGE="http://www.bzip.org/"

LICENSE="BZIP2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="static static-libs"

RDEPEND="abi_x86_32? (
		!<=app-emulation/emul-linux-x86-baselibs-20130224
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
	)"

S=${WORKDIR}

src_install() {
	dohostsyms /bin/bzip2 /bin/bunzip2 /bin/bzcat /usr/bin/bzcmp /usr/bin/bzdiff \
		/usr/bin/bzgrep /usr/bin/bzip2recover /usr/bin/bzless /usr/bin/bzmore 
	dohostoptsyms /usr/bin/bzegrep /usr/bin/bzfgrep
	if [ ! $(type -P bzegrep) ]; then
		echo "Making bzegrep symlink"
		dohostsym bzgrep /usr/bin/bzegrep
	fi
	if [ ! $(type -P bzfgrep) ]; then
		echo "Making bzfgrep symlink"
		dohostsym bzgrep /usr/bin/bzfgrep
	fi
}
