# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/prefix-chain-utils/prefix-chain-utils-0.2-r5.ebuild,v 1.2 2010/07/13 15:13:00 mr_bones_ Exp $

inherit prefix

DESCRIPTION="Chained EPREFIX utilities and wrappers"
HOMEPAGE="http://dev.gentoo.org/~mduft"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~ppc-aix ~ia64-hpux ~x86-interix ~x86-linux ~sparc-solaris ~x86-solaris ~x86-winnt"
IUSE="cray"

DEPEND=""
RDEPEND="sys-devel/gcc-config"

src_install() {
	cp "${FILESDIR}"/*.in "${T}"
	eprefixify "${T}"/*.in

	for x in "${T}"/*.in; do
		mv ${x} ${x%.in}
	done

	# install toolchain wrapper.
	wrapperdir=/usr/${CHOST}/gcc-bin/${CHOST}-prefix-chain-wrapper/${PV}
	wrappercfg=${CHOST}-prefix-chain-wrapper-${PV}

	exeinto $wrapperdir
	sed -i -e "s,@GENTOO_PORTAGE_CHOST@,${CHOST},g" "${T}"/prefix-chain-wrapper
	sed -i -e "s,@GENTOO_PORTAGE_BASE_EPREFIX@,$(portageq envvar BASE_EPREFIX),g" "${T}"/prefix-chain-wrapper
	sed -i -e "s,@GENTOO_PORTAGE_BASE_EPREFIX@,$(portageq envvar BASE_EPREFIX),g" "${T}"/startprefix
	doexe "${T}"/prefix-chain-wrapper

#	if use cray ; then
#		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/gcc
#		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/g++
#		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/cpp
#		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/c++
#		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/gfortran
#	else
		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-gcc
		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-g++
		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-cpp
		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-c++
		dosym $wrapperdir/prefix-chain-wrapper $wrapperdir/${CHOST}-gfortran

		dosym $wrapperdir/${CHOST}-gcc $wrapperdir/gcc
		dosym $wrapperdir/${CHOST}-g++ $wrapperdir/g++
		dosym $wrapperdir/${CHOST}-cpp $wrapperdir/cpp
		dosym $wrapperdir/${CHOST}-c++ $wrapperdir/c++
		dosym $wrapperdir/${CHOST}-gfortran $wrapperdir/gfortran
#	fi

	# LDPATH is required to keep gcc-config happy :(
	cat > "${T}"/$wrappercfg <<EOF
GCC_PATH="${EPREFIX}/$wrapperdir"
LDPATH="${EPREFIX}/$wrapperdir"
EOF

	insinto /etc/env.d/gcc
	doins "${T}"/$wrappercfg

	# install startprefix script.
	exeinto /
	doexe "${T}"/startprefix
}
