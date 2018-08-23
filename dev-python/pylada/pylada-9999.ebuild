# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 git-r3 cmake-utils

DESCRIPTION="High-Throughput Computational Physics Framework "
HOMEPAGE="https://github.com/pylada/pylada"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/pylada/pylada.git"
	SRC_URI=""
else
	SRC_URI=""
fi

LICENSE="GPL3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray python"

PATCHES=( "${FILESDIR}"/${P}-bw.patch )

DEPEND="
virtual/mpi
dev-libs/boost[mpi]
dev-cpp/eigen
dev-python/numpy[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}
>=sci-libs/scipy-0.11.0[${PYTHON_USEDEP}]
>=dev-python/ipython-0.13.0[${PYTHON_USEDEP}]
dev-python/quantities[${PYTHON_USEDEP}]
"
src_configure() {
	if use cray; then
		CC=cc
		CXX=CC
		FC=ftn
	else
		CC=mpicc
		CXX=mpicxx
		FC=mpif90
	fi
	GLOBALCMAKEARGS=( "-DCMAKE_C_COMPILER=$(which $CC)"
			  "-DCMAKE_CXX_COMPILER=$(which $CXX)"
			  "-DCMAKE_Fortran_COMPILER=$(which $FC)"
			)
	mycmakeargs=( ${GLOBALCMAKEARGS[@]} )
	cmake-utils_src_configure
}

