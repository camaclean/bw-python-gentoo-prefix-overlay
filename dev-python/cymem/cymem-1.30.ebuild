# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="Gate Cython calls to malloc/free behind Python ref-counted objects"
HOMEPAGE="https://pypi.python.org/pypi/cymem"
SRC_URI="https://pypi.python.org/packages/source/c/cymem/cymem-1.30.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_MODULES="cymem"

src_prepare() {
	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install
}

