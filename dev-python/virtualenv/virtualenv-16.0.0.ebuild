# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6,7} pypy{,3} )

inherit distutils-r1

DESCRIPTION="Virtual Python Environment builder"
HOMEPAGE="
	https://virtualenv.pypa.io/en/stable/
	https://pypi.org/project/virtualenv/
	https://github.com/pypa/virtualenv/
"
SRC_URI="https://github.com/pypa/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="bwpy-environ doc test"

RDEPEND=""
DEPEND="${RDEPEND}
	>=dev-python/setuptools-19.6.2[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )
	test? (
		dev-python/mock[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}]
	)"

DOCS=( docs/index.rst docs/changes.rst )

PATCHES=(
	"${FILESDIR}"/${PN}-12.1.1-skip-broken-test.patch
)

python_prepare_all() {
	distutils-r1_python_prepare_all
	use bwpy-environ && eapply "${FILESDIR}"/${PN}-15.1.0-bwpy-environ2.patch
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	py.test -v -v || die "Tests fail with ${EPYTHON}"
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/_build/html/. )
	distutils-r1_python_install_all
}
