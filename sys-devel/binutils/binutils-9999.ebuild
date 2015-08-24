# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.24-r1.ebuild,v 1.1 2014/01/07 04:43:47 patrick Exp $

PATCHVER="1.3"
ELF2FLT_VER=""
inherit hostsym

KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"

src_unpack() {
	mkdir -p $S
}

src_install() {
	dohostsym /usr/bin/addr2line \
		/usr/bin/ar \
		/usr/bin/as \
		/usr/bin/c++flit \
		/usr/bin/dwp \
		/usr/bin/elfedit \
		/usr/bin/gprof \
		/usr/bin/ld \
		/usr/bin/ld.bfd \
		/usr/bin/ld.gold \
		/usr/bin/nm \
		/usr/bin/objcopy \
		/usr/bin/objdump \
		/usr/bin/ranlib \
		/usr/bin/readelf \
		/usr/bin/size \
		/usr/bin/strings \
		/usr/bin/strip
}
