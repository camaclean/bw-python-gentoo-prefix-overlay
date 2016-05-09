# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )
DISTUTILS_OPTIONAL=1

inherit distutils-r1 subversion flag-o-matic

DESCRIPTION="Global Arrays PGAS library"
HOMEPAGE="http://hpc.pnl.gov/globalarrays/"
SRC_URI=""
ESVN_REPO_URI="https://svn.pnl.gov/svn/hpctools/branches/ga-5-4"
ESVN_OPTIONS="--no-auth-cache"
ESVN_USER="anonymous"
ESVN_PASSWORD="anonymous"

LICENSE="Unknown"
SLOT="0"
KEYWORDS="~amd64"
IUSE="blas cray cxx dmapp fortran gemini lapack mpi-pr mpi-pt mpi-ts python scalapack"

REQUIRED_USE="
	!cray? ( !gemini !dmapp )
	^^ ( dmapp gemini mpi-pr mpi-pt mpi-ts )
	python? ( ${PYTHON_REQUIRED_USE} )
"

DEPEND="mpi-pr? ( virtual/mpi )
	mpi-pt? ( virtual/mpi )
	mpi-ts? ( virtual/mpi )
	blas? ( virtual/blas )
	lapack? ( virtual/lapack )
	!cray? ( scalapack? ( virtual/scalapack ) )
	python? (
		dev-python/mpi4py[${PYTHON_USEDEP}]
        	${PYTHON_DEPS}
	)
"
RDEPEND="${DEPEND}"

if use gemini; then
	ENVMOD_REQUIRE="ugni gni_headers ntk onesided"
elif use dmapp; then
	ENVMOD_REQUIRE="dmapp ntk onesided"
fi

src_configure() {
	local blas lapack scalapack
	if use cray; then
		blas="-lsci_gnu"
		lapack="-lsci_gnu"
		scalapack="-lscalapack"
		export CC="cc"
		export CXX="CC"
		export FC="ftn"
		export MPICC="cc"
		export MPICXX="CC"
		export MPIFC="ftn"
		if use dmapp; then
			append-flags "$(pkg-config --cflags cray-dmapp)"
			append-ldflags "$(pkg-config --libs cray-dmapp)"
		fi
	else
		export CC="mpicc"
		export CXX="mpicxx"
	fi
	econf \
		$(use_with blas blas ${blas}) \
		$(use_with lapack lapack ${lapack}) \
		$(use_with scalapack scalapack ${scalapack}) \
		$(use_with dmapp) \
		$(use_with gemini) \
		$(use_with mpi-ts) \
		$(use_with mpi-pr) \
		$(use_with mpi-pt) \
		$(use_enable cxx) \
		$(use_enable fortran f77) \
		--enable-i4 \
		--enable-shared \
		--with-pic
}

src_compile() {
	default
	if use python; then
		cd python || die
		distutils-r1_src_compile
	fi
}

src_install() {
	default
	if use python; then
		cd python || die
		distutils-r1_src_install
	fi
}
