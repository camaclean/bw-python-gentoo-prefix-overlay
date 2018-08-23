# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit python-utils-r1
PYTHON_COMPAT=( "${_PYTHON_ALL_IMPLS[@]}" )

inherit distutils-r1 python-r1

DESCRIPTION="Set up sitecustomize.d for Python"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_unpack() {
	mkdir -p "$S"
}

src_prepare() {
	prepare_files() {
		mkdir -p "${BUILD_DIR}"
		sed -e "s/@PYTHON@/${EPYTHON}/" "${FILESDIR}"/${P}-sitecustomize.py.in > "${BUILD_DIR}"/sitecustomize.py || die "Sed failed"
	}
	python_foreach_impl prepare_files
}

src_compile() {
	:
}

python_install() {
	cd "${BUILD_DIR}"
	insinto /usr/lib/${EPYTHON}/site-packages
	doins sitecustomize.py
}
