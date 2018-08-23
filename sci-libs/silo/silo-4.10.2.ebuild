# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils fortran-2

DESCRIPTION="A mesh and field I/O library and scientific database"
HOMEPAGE="https://wci.llnl.gov/simulation/computer-codes/silo"
SRC_URI="https://wci.llnl.gov/content/assets/docs/simulation/computer-codes/${PN}/${P}/${P}.tar.gz"
SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64 ~x86"
IUSE="cray hdf5 mpi +silex static-libs qt4 test"

REQUIRED_USE="silex? ( qt4 )"

RDEPEND="
	hdf5? ( sci-libs/hdf5 )
	qt4? ( dev-qt/qtgui:4 )"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${P}-qtlibs.patch"
	epatch "${FILESDIR}/${P}-tests.patch"
	epatch "${FILESDIR}/${P}-hdf5-parallel.patch"
}

src_configure() {
	if use cray; then
		local hdf5_opts="${HDF5_DIR}/include,${HDF5_DIR}/lib"
		if use mpi; then
			export CC=cc
			export CXX=CC
			export FC=ftn
			export F77=ftn
			export F90=ftn
		fi
		export CFLAGS="${CFLAGS} -I$(get_eprefix x11-libs/libX11 RDEPEND)/usr/include"
		export CXXFLAGS="${CXXFLAGS} -I$(get_eprefix x11-libs/libX11 RDEPEND)/usr/include"
		export LDFLAGS="${LDFLAGS} -L$(get_eprefix x11-libs/libX11 RDEPEND)/usr/lib"
	else
		local hdf5_opts="$(get_eprefix sci-libs/hdf5)/usr/include,$(get_eprefix sci-libs/hdf5)/usr/lib${LIB_LOCATION_SUFFIX}"
	fi
	econf \
		--enable-install-lite-headers \
		--enable-shared \
		--x-libraries="$(get_eprefix x11-libs/libX11)/usr/lib" \
		--x-includes="$(get_eprefix x11-libs/libX11)/usr/include" \
		$(use_enable silex silex ) \
		$(use_enable static-libs static ) \
		$(use_with qt4 Qt-lib-dir "$(get_eprefix dev-qt/qtcore:4)"/usr/lib${LIB_LOCATION_SUFFIX}/qt4 ) \
		$(use_with qt4 Qt-include-dir "$(get_eprefix dev-qt/qtcore:4)"/usr/include/qt4 ) \
		$(use_with hdf5 hdf5 ${hdf5_opts} )
}

src_install() {
	default
	rm ${ED}usr/lib/libsiloh5.la || die "Could not delete libtool files"
}
