# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MAKEFILE_GENERATOR=ninja
inherit cmake-utils

DESCRIPTION="Tensors and Dynamic neural networks in Python with strong GPU acceleration"
HOMEPAGE="http://pytorch.org"
SRC_URI="https://github.com/pytorch/pytorch/archive/v${PV}.tar.gz -> pytorch-${PV}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE="cuda"
RDEPEND="~dev-libs/torch-0.3.0
~dev-libs/torch-sparse-0.3.0
~dev-libs/torch-nn-0.3.0
cuda? (
  ~dev-libs/torch-cuda-0.3.0
  ~dev-libs/torch-cuda-sparse-0.3.0
  ~dev-libs/torch-cunn-0.3.0
)"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/pytorch-${PV}/torch/lib/ATen

PATCHES=( "${FILESDIR}"/${PN}-0.3.0-standalone.patch )

src_configure() {

	CWRAP_FILES="${S}/Declarations.cwrap;${S}/Local.cwrap;${S}/../THNN/generic/THNN.h;${S}/../THCUNN/generic/THCUNN.h;$S/nn.yaml"
	export CFLAGS="${CFLAGS} -DTH_INDEX_BASE=0"
	export CXXFLAGS="-std=c++11 ${CXXFLAGS} -DTH_INDEX_BASE=0"
	local mycmakeargs=( 
		-Dcwrap_files=${CWRAP_FILES}
	)
	cmake-utils_src_configure
}
