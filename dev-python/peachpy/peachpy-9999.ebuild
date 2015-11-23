# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1 git-2

DESCRIPTION="Portable Efficient Assembly Codegen in Higher-level Python"
HOMEPAGE="https://github.com/Maratyszcza/PeachPy"
if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/Maratyszcza/PeachPy.git"
else
	SRC_URI="https://pypi.python.org/packages/source/P/PeachPy/PeachPy-${PV}.zip -> ${P}.tar.gz"
fi

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="dev-python/enum34
	 dev-python/six
	 >=dev-python/opcodes-0.3.8
	 ${DEPEND}"

PYTHON_MODULES="peachpy"

src_prepare() {
	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install
}

