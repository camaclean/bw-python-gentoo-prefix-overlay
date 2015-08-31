# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.9-r4.ebuild,v 1.3 2015/04/06 20:11:01 vapier Exp $

EAPI="4"
inherit eutils flag-o-matic toolchain-funcs multilib-minimal libtool

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="ada +cxx debug doc gpm minimal profile static-libs tinfo trace unicode"

DEPEND="gpm? ( sys-libs/gpm )"
#	berkdb? ( sys-libs/db )"
RDEPEND="${DEPEND}
	!<x11-terms/rxvt-unicode-9.06-r3
	abi_x86_32? (
		!<=app-emulation/emul-linux-x86-baselibs-20130224-r12
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
	)"
# Put the MULTILIB_USEDEP on gpm in PDEPEND only to avoid circular deps.
# We can move it to DEPEND and drop the --with-gpm=libgpm.so.1 from the econf
# line below once we can assume multilib gpm is available everywhere.
PDEPEND="gpm? ( sys-libs/gpm[${MULTILIB_USEDEP}] )"

S=${WORKDIR}

src_install() {
	mkdir -p ${D}/${EPREFIX}/usr/lib/pkgconfig/
	cat >>${D}/${EPREFIX}/usr/lib/pkgconfig/ncurses.pc <<EOT
prefix=/usr
exec_prefix=\${prefix}
libdir=/usr/lib64
includedir=\${prefix}/include/ncurses
major_version=5
version=5.9.20110404

Name: ncurses
Description: ncurses 5.9 library
Version: \${version}
Requires: 
Libs: -L\${libdir} -lncurses  
Cflags: -I\${includedir}
EOT
}
