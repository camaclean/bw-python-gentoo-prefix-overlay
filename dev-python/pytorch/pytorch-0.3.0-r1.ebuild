# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{5,6})

inherit distutils-r1

DESCRIPTION="Tensors and Dynamic neural networks in Python with strong GPU acceleration"
HOMEPAGE="http://pytorch.org"
SRC_URI="https://github.com/pytorch/pytorch/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE="cuda cray mpi"
DEPEND="~dev-libs/torch-0.3.0
~dev-libs/torch-sparse-0.3.0
~dev-libs/torch-nn-0.3.0
~dev-libs/ATen-0.3.0
~dev-libs/nanopb-20170723
~dev-libs/pybind11-20170821
cuda? (
	dev-libs/nccl
	~dev-libs/torch-cunn-0.3.0
	~dev-libs/torch-cuda-0.3.0
	~dev-libs/torch-cuda-sparse-0.3.0
)
mpi? (
	virtual/mpi
	~dev-libs/torch-distributed-0.3.0[cuda?,cray?]
	~dev-libs/torch-libshm-0.3.0
)
"
RDEPEND="${DEPEND}"

PYTHON_MODULES="pytorch"

src_prepare() {
	eapply "${FILESDIR}"/pytorch-0.3.0-old-nccl.patch 
	eapply "${FILESDIR}"/pytorch-0.3.0-standalone.patch
	sed -e "s:@GENTOO_EPREFIX@:${EPREFIX}:g" -i "${S}"/torch/_thnn/utils.py || die
	sed -e "s:@GENTOO_EPREFIX@:${EPREFIX}:g" -i "${S}"/torch/__init__.py || die
	distutils-r1_src_prepare
}

src_configure() {
	export PYTORCH_BUILD_VERSION=0.3.0
	export PYTORCH_BUILD_NUMBER=0
	if use mpi; then
		if use cray; then
			export CC=cc
			export CXX=CC
			export CRAYPE_LINK_TYPE=dynamic
			export CRAY_ADD_RPATH=yes
		else
			export CC=mpicc
			export CXX=mpicxx
		fi
	else
		export NO_DISTRIBUTED=1
	fi
	if ! use cuda; then
		export NO_CUDA=1
	fi
}
