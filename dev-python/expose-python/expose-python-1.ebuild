# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Symlink python installs into public bin directory"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	mkdir -p ${D}/${EPREFIX}/public/bin
	for i in ${EPREFIX}/usr/bin/python*; do
		ln -snf $i ${D}/${EPREFIX}/public/bin
	done
}
