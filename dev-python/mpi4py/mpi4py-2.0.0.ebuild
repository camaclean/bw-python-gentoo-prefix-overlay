# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4} )

inherit distutils-r1 craymodules

DESCRIPTION="Message Passing Interface for Python"
HOMEPAGE="https://code.google.com/p/mpi4py/ https://pypi.python.org/pypi/mpi4py"
SRC_URI="https://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 amd64-linux x86 x86-linux"
#KEYWORDS=""
IUSE="doc examples test cray"

RDEPEND="virtual/mpi"
DEPEND="${RDEPEND}
	test? ( dev-python/nose[${PYTHON_USEDEP}]
	virtual/mpi[romio] )"
DISTUTILS_IN_SOURCE_BUILD=1

if use cray; then
	module unload acml
	export CRAYPE_LINK_TYPE=dynamic
	export CRAY_ADD_RPATH=yes
fi

python_prepare_all() {
	# not needed on install
	rm -r docs/source || die
	export FFLAGS="$(echo "$FFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
	export CFLAGS="$(echo "$CFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
	export CXXFLAGS="$(echo "$CXXFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
	export LDFLAGS="$(echo "$LDFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
	cat >> mpi.cfg <<EOT
# Cray MPI and compiler
[cray]
mpicc = $(which cc)
mpicxx = $(which CC)
mpif77 = $(which ftn)
mpif90 = $(which ftn)
mpif95 = $(which ftn)
#extra_link_args = -dynamic
EOT
	distutils-r1_python_prepare_all
}

src_compile() {
	export FAKEROOTKEY=1
	if use cray ; then
		export MPICFG="cray"
		export FFLAGS="$(echo "$FFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
		export CFLAGS="$(echo "$CFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
		export CXXFLAGS="$(echo "$CXXFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
		export LDFLAGS="$(echo "$LDFLAGS" | sed -e "s/-O2//" -e "s/-march=bdver1//")"
		distutils-r1_src_compile
	else
		distutils-r1_src_compile
	fi
}

python_test() {
	echo "Beginning test phase"
	pushd "${BUILD_DIR}"/../ &> /dev/null
	mpiexec -n 2 "${PYTHON}" ./test/runtests.py -v || die "Testsuite failed under ${EPYTHON}"
	popd &> /dev/null
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/. )
	use examples && local EXAMPLES=( demo/. )
	distutils-r1_python_install_all
}
