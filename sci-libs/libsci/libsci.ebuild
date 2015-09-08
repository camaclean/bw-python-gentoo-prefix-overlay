# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Cray science libraries"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}

pkg_install() {
	ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
	ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
	ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
}
