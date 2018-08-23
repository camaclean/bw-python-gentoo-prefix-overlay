# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit python-utils-r1
PYTHON_COMPAT=( "${_PYTHON_ALL_IMPLS[@]}" )

inherit distutils-r1 python-r1

DESCRIPTION="Log imported python modules to syslog"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=">=dev-python/python-sitecustomized-0.1.0
	${DEPEND}"

src_unpack() {
	mkdir -p "$S"
}

python_prepare() {
	sed -e "s|@GENTOO_EPREFIX@|${EPREFIX}|g" "${FILESDIR}"/${P}-log-imports.py.in > "${BUILD_DIR}"/log-imports.py || die "Sed failed"
}

src_compile() {
	:
}

python_install() {
	cd build
	echo `pwd`
	insinto /usr/lib/${EPYTHON}/site-packages/sitecustomize.d
	doins log-imports.py
}
