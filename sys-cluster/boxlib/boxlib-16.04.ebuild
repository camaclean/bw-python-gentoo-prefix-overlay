# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils flag-o-matic

DESCRIPTION="A block-structured AMR framework"
HOMEPAGE="https://ccse.lbl.gov/BoxLib/"
SRC_URI="https://github.com/BoxLib-Codes/BoxLib/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="Unknown"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+backtrace cray mpi openmp particles profiling spacedim1 spacedim2 +spacedim3 static-libs"

REQUIRED_USE="
^^ ( spacedim1 spacedim2 spacedim3 )
"

DEPEND="
mpi? ( virtual/mpi )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/BoxLib-${PV}"

PATCHES=(
"${FILESDIR}"/boxlib-16.04-fix-compiler-flags.patch
"${FILESDIR}"/boxlib-16.04-install-locations.patch
)

boxlib_use_int() {
	use $1 && echo 1 || echo 0
}

boxlib_use_enable() {
	[ $# -eq 0 -o $# -gt 2 ] && die "boxlib_use_enable_int requires 1 or 2 arguments"
	echo "-DENABLE_${2:-${1^^}}=$(boxlib_use_int $1)"
}

src_prepare() {
	cmake-utils_src_prepare
	cp Src/C_BaseLib/BLBackTrace.H Src/F_BaseLib/
}

src_configure() {
	local spacedim=3
	use spacedim1 && spacedim=1
	use spacedim2 && spacedim=2
	local use_particles use_mpi
	if use mpi; then
		if use cray; then
			export CRAYPE_LINK_TYPE=dynamic
			export CC=cc
			export CXX=CC
			export FC=ftn
		else
			export CC=mpicc
			export CXX=mpicxx
		fi
	fi
	local mycmakeargs=(
		"-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
		"-DBL_SPACEDIM=${spacedim}"
		$(boxlib_use_enable mpi)
		$(boxlib_use_enable openmp OpenMP)
		"-DBL_USE_PARTICLES=$(boxlib_use_int particles)"
		$(boxlib_use_enable profiling)
		$(boxlib_use_enable backtrace)
	)
	if use static-libs; then
		mycmakeargs+=(
			"-DBUILD_STATIC_LIBS:BOOL=ON"
		)
	else
		mycmakeargs+=(
			"-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON"
			"-DBUILD_SHARED_LIBS:BOOL=ON"
		)
	fi
	cmake-utils_src_configure
}
