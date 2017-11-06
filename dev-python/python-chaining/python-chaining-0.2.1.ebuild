# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1 python-r1

DESCRIPTION="Set up prefix chaining for Python"
HOMEPAGE=""
SRC_URI=""

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=">=dev-python/python-sitecustomized-0.1.0[${PYTHON_USEDEP}]
	${DEPEND}"

src_unpack() {
	mkdir -p "$S"
}

src_compile() { 
	: 
}

src_prepare() {
	prepare_files() {
		mkdir -p "${BUILD_DIR}"
		sed -e "s/@PYTHON@/${EPYTHON}/" "${FILESDIR}"/${P}-python-chaining.py.in > "${BUILD_DIR}"/python-chaining.py || die "Sed failed"
	}
	python_foreach_impl prepare_files
}

python_install() {
	cd "${BUILD_DIR}"
	insinto /usr/lib/${EPYTHON}/site-packages/sitecustomize.d
	doins python-chaining.py
}
