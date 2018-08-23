# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc-config/gcc-config-1.8.ebuild,v 1.1 2012/11/19 06:55:06 vapier Exp $

EAPI=6

inherit hostsym

DESCRIPTION="Use the host gcc on Cray"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="${PV}"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="cray"

REQUIRED_USE="cray"

S="${WORKDIR}"

src_compile() {
	cat >"${T}"/${CHOST}-${PV} <<-EOF
		LDPATH="${EPREFIX%/}/usr/lib/gcc/${CHOST}/${PV}:${EPREFIX%/}/usr/lib/gcc/${CHOST}/${PV}-32"
		MANPATH="${EPREFIX%/}/usr/share/gcc-data/${CHOST}/${PV}/man"
		INFOPATH="${EPREFIX%/}/usr/share/gcc-data/${CHOST}/${PV}/info"
		STDCXX_INCDIR="g++-v${PV%%.*}"
		CTARGET="${CHOST}"
		GCC_SPECS=""
		MULTIOSDIRS="../lib64:../lib"
		GCC_PATH="${EPREFIX%/}/usr/${CHOST}/gcc-bin/${PV}"
		EOF
}

#HOST_CHOST="x86_64-suse-linux"
HOST_CHOST="${CHOST/pc-linux-gnu/suse-linux}"

src_install() {
	dodir /usr/${CHOST}/gcc-bin/${PV}
	for i in c++ cpp g++ gcc gcc-ar gcc-nm gcc-ranlib gcov gcov-tool gfortran \
		${CHOST}-c++ ${CHOST}-gcc ${CHOST}-g++ \
		${CHOST}-gcc-ar ${CHOST}-gcc-${PV} \
		${CHOST}-gcc-ranlib ${CHOST}-gfortran \
		${CHOST}-gcc-nm
	do
		dohostsym /opt/gcc/${PV}/snos/bin/${i/${CHOST}/${HOST_CHOST}} /usr/${CHOST}/gcc-bin/${PV}/${i}
	done
	[ -e "/opt/gcc/${PV}/snos/bin/gcov-dump" ] && dohostsym /opt/gcc/${PV}/snos/bin/gconv-dump /usr/${CHOST}/gcc-bin/${PV}/gconv-dump
	[ -e "/opt/gcc/${PV}/snos/bin/${HOST_CHOST}-gcov" ] && dohostsym /opt/gcc/${PV}/snos/bin/${HOST_CHOST}-gcov \
		/usr/${CHOST}/gcc-bin/${PV}/${CHOST}-gcov || dohostsym /opt/gcc/${PV}/snos/bin/gcov \
		/usr/${CHOST}/gcc-bin/${PV}/${CHOST}-gcov
	[ -e "/opt/gcc/${PV}/snos/bin/${HOST_CHOST}-cpp" ] && dohostsym /opt/gcc/${PV}/snos/bin/${HOST_CHOST}-cpp \
		/usr/${CHOST}/gcc-bin/${PV}/${CHOST}-cpp || dohostsym /opt/gcc/${PV}/snos/bin/cpp \
		/usr/${CHOST}/gcc-bin/${PV}/${CHOST}-cpp
	dodir /usr/bin
	for i in c++ cpp g++ gcc gcov gfortran; do
		dohostsym ${ED%/}/usr/${CHOST}/gcc-bin/${PV}/${CHOST}-${i} /usr/bin/${i}-${PV}
		dohostsym ${ED%/}/usr/${CHOST}/gcc-bin/${PV}/${CHOST}-${i} /usr/bin/${CHOST}-${i}-${PV}
	done
	dodir /usr/share/gcc-data/${CHOST}/${PV}
	dohostsym /opt/gcc/${PV}/snos/share/man /usr/share/gcc-data/${CHOST}/${PV}/man
	dohostsym /opt/gcc/${PV}/snos/share/info /usr/share/gcc-data/${CHOST}/${PV}/info
	dodir /usr/lib/gcc/${CHOST}
	dohostsym /opt/gcc/${PV}/snos/lib/gcc/${HOST_CHOST}/${PV} /usr/lib/gcc/${CHOST}/${PV}
	insinto /etc/env.d/gcc
	doins "${T}"/${CHOST}-${PV}
}

pkg_postinst() {
	local x
	for x in $(gcc-config -C -l 2>/dev/null | awk '$NF == "*" { print $2 }') ; do
		gcc-config ${x}
	done
}
