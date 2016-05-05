# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
#PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit cmake-utils

DESCRIPTION="Industrial-strength Natural Language Processing with Python and Cython"
HOMEPAGE="https://github.com/honnibal/spaCy"
SRC_URI="https://www.gridpack.org/wiki/images/6/6a/Gridpack-3-0.tar.gz -> ${P}.tar.gz"

LICENSE="GridPACK"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE="cray examples glpk mpi-pr"
DEPEND="
sys-cluster/globalarrays[cxx,mpi-pr=]
sci-mathematics/petsc[cxx,mpi]
dev-libs/boost[mpi,static-libs]
glpk? ( sci-mathematics/glpk )
!cray? ( sci-libs/parmetis )
"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${P}.patch" )

S="${WORKDIR}/gridpack-3-0"

pkg_pretend() {
	has_version "sci-libs/parmetis" || export ENVMOD_REQUIRE="$ENVMOD_REQUIRE cray-tpsl"
}

CMAKE_USE_DIR="${S}/src"

src_prepare() {
	cmake-utils_src_prepare

	if ! use examples; then
		cd src
		comment_add_subdirectory applications/examples/hello_world
		comment_add_subdirectory applications/examples/resistor_grid
	fi
	epatch "${FILESDIR}/${P}-notests.patch"
}

src_configure() {
	local mycmakeargs=() save_IFS=$IFS p petsc_prefix prefixes
	IFS=':'
	prefixes="$EPREFIX:$PORTAGE_READONLY_EPREFIXES"
	for p in ${prefixes%:}; do
		if [ -f "$p/usr/lib/libpetsc.so" ]; then
			petsc_prefix=$p
			break
		fi
	done
	IFS=$save_IFS

	mycmakeargs+=(	"-DPETSC_INCLUDES=$petsc_prefix/usr/include/petsc" )
	mycmakeargs+=(	"-DPETSC_LIBRARIES=$petsc_prefix/usr/lib/libpetsc.so" )
	has_version "sci-mathematics/petsc[-complex-scalars]" && mycmakeargs+=( "-DPETSC_ARCH=linux-gnu-cxx-opt" )
	has_version "sci-mathematics/petsc[complex-scalars]"  && mycmakeargs+=( "-DPETSC_ARCH=linux-gnu-cxx-complex-opt" )

	mycmakeargs+=(  "$(cmake-utils_use_use glpk GLPK)" )
	mycmakeargs+=(  "$(cmake-utils_use_use mpi-pr PROGRESS_RANKS)" )

	if use cray; then
		export CC=cc
		export CXX=CC
		export MPICC=cc
		export MPICXX=CC
		mycmakeargs+=(	"-DPETSC_EXECUTABLE_RUNS=true"
				"-DPARMETIS_TEST_RUNS=true"
				"-DGA_TEST_RUNS=true" )
		mycmakeargs+=(  "-DPARMETIS_LIBRARY=$CRAY_TPSL_PREFIX_DIR/lib/libparmetis.so" )
		mycmakeargs+=(  "-DPARMETIS_INCLUDE_DIR=$CRAY_TPSL_PREFIX_DIR/include/" )
		mycmakeargs+=(  "-DMETIS_LIBRARY=${CRAY_TPSL_PREFIX_DIR}/lib/libmetis.so" )
	else
		mycmakeargs+=(  "-DPARMETIS_LIBRARY=$EPREFIX/usr/lib/libparmetis.so" )
		mycmakeargs+=(  "-DPARMETIS_INCLUDE_DIR=$EPREFIX/usr/include/" )
		mycmakeargs+=(  "-DMETIS_LIBRARY=$EPREFIX/usr/lib/libmetis.so" )
	fi 


	cmake-utils_src_configure
}
