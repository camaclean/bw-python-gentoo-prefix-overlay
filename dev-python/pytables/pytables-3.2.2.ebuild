# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

MY_PN=tables
MY_P=${MY_PN}-${PV}

inherit distutils-r1

DESCRIPTION="Hierarchical datasets for Python"
HOMEPAGE="http://www.pytables.org/"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
LICENSE="BSD"
IUSE="cray doc examples"

RDEPEND="
	app-arch/bzip2:0=
	dev-libs/c-blosc:0=[hdf5]
	dev-libs/lzo:2=
	>=dev-python/numpy-1.7.1[${PYTHON_USEDEP}]
	>=dev-python/numexpr-2.4[${PYTHON_USEDEP}]
	>=sci-libs/hdf5-1.8.4:0="
DEPEND="${RDEPEND}
	>=dev-python/cython-0.14[${PYTHON_USEDEP}]"

S="${WORKDIR}/${MY_P}"

DOCS=( ANNOUNCE.txt RELEASE_NOTES.txt THANKS )

PATCHES=(
	"${FILESDIR}"/${PN}-3.2.0-blosc.patch
	)

python_prepare_all() {
	if use cray; then
		export HDF5_DIR
		export CC=cc
		export CXX=CC
		export FC=ftn
		export F77=ftn
		export F90=ftn
		export F95=ftn
		export F08=ftn
		#export CFLAGS="$CRAY_CFLAGS $CFLAGS"
		#export FFLAGS="$CRAY_CFLAGS $FFLAGS"
		#export LDFLAGS="$CRAY_LDFLAGS $LDFLAGS"
	else
		export HDF5_DIR="${EPREFIX}"/usr
	fi
	rm tables/*.c || die
	sed \
		-e "s:/usr:${EPREFIX}/usr:g" \
		-e 's:"c-blosc/hdf5/blosc_filter.c"::g' \
		-i setup.py || die
	rm -r c-blosc/{blosc,hdf5,internal-complibs} || die
	distutils-r1_python_prepare_all
}

python_compile() {
	python_is_python3 || local -x CFLAGS="${CFLAGS} -fno-strict-aliasing"
	distutils-r1_python_compile
}

python_test() {
	cd "${BUILD_DIR}"/lib* || die
	${EPYTHON} tables/tests/test_all.py || die
}

python_install_all() {
	if use doc; then
		HTML_DOCS=( doc/html/. )
		DOCS+=( doc/scripts )
	fi
	distutils-r1_python_install_all

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
		doins -r contrib
	fi
}
