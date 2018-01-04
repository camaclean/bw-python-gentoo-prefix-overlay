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
IUSE=""
RDEPEND="~dev-libs/torch-0.3.0"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/pytorch-${PV}/torch/lib/libshm

PATCHES=( "${FILESDIR}"/torch-libshm-0.3.0-standalone.patch )

src_configure() {
	cmake-utils_src_configure
}
