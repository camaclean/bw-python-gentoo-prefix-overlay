# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/netcdf4-python/netcdf4-python-1.0.4.ebuild,v 1.5 2015/06/13 02:18:27 zmedico Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )

inherit eutils distutils-r1

MY_PN="netCDF4"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python/numpy interface to netCDF"
HOMEPAGE="https://code.google.com/p/netcdf4-python"
SRC_URI="https://netcdf4-python.googlecode.com/files/${MY_P}.tar.gz"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="test cray"

RDEPEND="
	dev-python/numpy
	sci-libs/hdf5
	sci-libs/netcdf:=[hdf]"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/${MY_P}

src_prepare() {
	if use cray; then
		export NETCDF4_DIR="$NETCDF_DIR"
		export CC=cc
		export FC=ftn
		export F77=ftn
		export F90=ftn
		export F95=ftn
		export F08=ftn
		#export CFLAGS="$CRAY_CFLAGS $CFLAGS"
		#export FFLAGS="$CRAY_CFLAGS $FFLAGS"
		#export LDFLAGS="$CRAY_LDFLAGS $LDFLAGS"
	fi
}

python_test() {
	cd test || die
	${PYTHON} run_all.py || die
}
