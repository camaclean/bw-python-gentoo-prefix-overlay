# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{5,6})

inherit distutils-r1

DESCRIPTION="Tensors and Dynamic neural networks in Python with strong GPU acceleration"
HOMEPAGE="http://pytorch.org"
GLOO_COMMIT="05ad98aeb66fabc7c8126e6068d4a70134d4b80d"
NANOPB_COMMIT="14efb1a47a496652ab08b1ebcefb0ea24ae4a5e4"
PYBIND11_COMMIT="9f6a636e547fc70a02fa48436449aad67080698f"
SRC_URI="https://github.com/pytorch/pytorch/archive/v${PV}.tar.gz -> ${P}.tar.gz
https://api.github.com/repos/facebookincubator/gloo/tarball/${GLOO_COMMIT} -> gloo-${GLOO_COMMIT:0:7}.tar.gz
https://api.github.com/repos/nanopb/nanopb/tarball/${NANOPB_COMMIT} -> nanopb-${NANOPB_COMMIT:0:7}.tar.gz
https://api.github.com/repos/pybind/pybind11/tarball/${PYBIND11_COMMIT} -> pybind11-${PYBIND11_COMMIT:0:7}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_MODULES="pytorch"

PATCHES=( "${FILESDIR}"/torch-0.3.0-old-nccl.patch )

src_prepare() {
	mv -fT "${WORKDIR}"/facebookincubator-gloo-${GLOO_COMMIT:0:7} ${S}/torch/lib/gloo || die
	mv -fT "${WORKDIR}"/nanopb-nanopb-${NANOPB_COMMIT:0:7} ${S}/torch/lib/nanopb || die
	mv -fT "${WORKDIR}"/pybind-pybind11-${PYBIND11_COMMIT:0:7} ${S}/torch/lib/pybind11 || die
	distutils-r1_src_prepare
}

src_compile() {
	# Rebuilds during install phase
	:
}
