# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Cray science libraries"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="openmp mpi cuda"

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	mkdir -p ${D}/${EPREFIX}/usr/lib/pkgconfig
	if use cuda; then
		ln -snf ${CRAY_LIBSCI_ACC_PREFIX_DIR}/lib/pkgconfig/sci_acc_nv35.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
		ln -snf ${CRAY_LIBSCI_ACC_PREFIX_DIR}/lib/pkgconfig/sci_acc_nv35.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
		if use openmp; then
			ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mp.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
		else
			ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
		fi
	else
		if use mpi ; then
			if use openmp; then
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi_mp.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi_mp.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi_mp.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
			else
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mpi.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
			fi
		else
			if use openmp; then
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mp.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mp.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci_mp.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
			else
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/blas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/cblas.pc
				ln -snf $CRAY_LIBSCI_PREFIX_DIR/lib/pkgconfig/sci.pc ${D}/${EPREFIX}/usr/lib/pkgconfig/lapack.pc
			fi
		fi
	fi
}
