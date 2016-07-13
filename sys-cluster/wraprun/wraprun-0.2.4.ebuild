# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit cmake-utils distutils-r1 prefix

DESCRIPTION="A flexible ALPS/Aprun task bundler"
HOMEPAGE="https://www.olcf.ornl.gov/kb_articles/wraprun/"
SRC_URI="https://github.com/olcf/wraprun/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray"

REQUIRED_USE="cray"
DEPEND="dev-util/cmake"
RDEPEND="${DEPEND}"

PY_S="$S/python"

ENVMOD="-darshan"

src_prepare()
{
	sed -e 's/"mpi.h"/<mpi.h>/g' -i src/split.c
	epatch "${FILESDIR}"/0.2.4-man.patch
	cmake-utils_src_prepare
	cd "${PY_S}"
        S="${PY_S}" distutils-r1_src_prepare
}

src_configure()
{
	CC=cc
	CXX=CC
	tc-export CC CXX
	#envmod_modify_modules $ENVMOD
	cmake-utils_src_configure
	cd "${PY_S}"
        S="${PY_S}" distutils-r1_src_configure
}

src_compile()
{	
	cmake-utils_src_compile
	cd "${PY_S}"
        S="${PY_S}" distutils-r1_src_compile
}

src_install()
{
	cmake-utils_src_install
	eprefixify share/man/man1/wraprun.1
	doman share/man/man1/wraprun.1
	cd "${PY_S}"
        S="${PY_S}" distutils-r1_src_install
}
