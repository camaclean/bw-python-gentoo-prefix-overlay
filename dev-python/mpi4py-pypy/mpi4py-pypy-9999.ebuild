# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( pypy pypy3 )

inherit distutils-r1 git-2

DESCRIPTION="Message Passing Interface for Python"
HOMEPAGE="https://code.google.com/p/mpi4py/ https://pypi.python.org/pypi/mpi4py"
if [[ $PV == 9999 ]]; then
	EGIT_REPO_URI="https://bitbucket.org/mpi4py/mpi4py.git"
	SRC_URI=""
else
	SRC_URI="https://${PN}.googlecode.com/files/${P}.tar.gz"
fi

LICENSE="BSD"
SLOT="0"
#KEYWORDS="amd64 amd64-linux x86 x86-linux"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="doc examples test cray"

RDEPEND="virtual/mpi"
DEPEND="${RDEPEND}
	test? ( dev-python/nose[${PYTHON_USEDEP}]
	virtual/mpi )"
DISTUTILS_IN_SOURCE_BUILD=1

python_prepare_all() {
	# not needed on install
	rm -r docs/source || die
	cat >> mpi.cfg <<EOT
# Cray MPI and compiler
[cray]
mpicc = $(which cc)
mpicxx = $(which CC)
mpif77 = $(which ftn)
mpif90 = $(which ftn)
mpif95 = $(which ftn)
extra_link_args = -shared
EOT
	distutils-r1_python_prepare_all
}

src_compile() {
	export FAKEROOTKEY=1
	if use cray ; then
		export MPICFG="cray"
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
