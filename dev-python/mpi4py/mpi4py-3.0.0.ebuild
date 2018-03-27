# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="Message Passing Interface for Python"
HOMEPAGE="https://bitbucket.org/mpi4py/ https://pypi.python.org/pypi/mpi4py"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="cray doc examples test"

RDEPEND="virtual/mpi"
DEPEND="${RDEPEND}
	test? ( dev-python/nose[${PYTHON_USEDEP}]
	virtual/mpi[romio] )"
DISTUTILS_IN_SOURCE_BUILD=1

python_prepare_all() {
	# not needed on install
	rm -vr docs/source || die
        cat >> mpi.cfg <<EOT
# Cray MPI and compiler
[cray]
mpicc = cc
mpicxx = CC
mpif77 = ftn
mpif90 = ftn
mpif95 = ftn
EOT
	use cray && export MPICFG="cray"
	export CRAYPE_LINK_TYPE=dynamic
	export CRAY_ADD_RPATH="yes"
	distutils-r1_python_prepare_all
}

src_compile() {
	export FAKEROOTKEY=1
	distutils-r1_src_compile
	esetup.py build_exe
}

python_test() {
	echo "Beginning test phase"
	pushd "${BUILD_DIR}"/../ &> /dev/null || die
	mpiexec -n 2 "${PYTHON}" ./test/runtests.py -v || die "Testsuite failed under ${EPYTHON}"
	popd &> /dev/null || die
}

python_install() {
       distutils-r1_python_install
       esetup.py install_exe
       dosym ${EPREFIX%/}/usr/lib/python-exec/${EPYTHON}/${EPYTHON}-mpi /usr/bin/${EPYTHON}-mpi
       dosym ${EPREFIX%/}/usr/lib/python-exec/${EPYTHON}/${EPYTHON}-mpi /usr/lib/python-exec/${EPYTHON}/python-mpi
}


python_install_all() {
	use doc && local HTML_DOCS=( docs/. )
	use examples && local DOCS=( demo )
	distutils-r1_python_install_all
	dosym ${EPREFIX%/}/usr/bin/python-exec2c /usr/bin/python-mpi
}
