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
IUSE="mpi"

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	mkdir -p ${D}/${EPREFIX}/usr/lib/pkgconfig
	if use mpi ; then
		ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
		ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
		ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
	else
		ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
		ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
		ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
	fi
}
