# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CUDA_PV=9.1

inherit versionator

DESCRIPTION="NVIDIA Accelerated Deep Learning on GPU library"
HOMEPAGE="https://developer.nvidia.com/cuDNN"

MY_PV_MAJOR=$(get_major_version)
SRC_URI="cudnn-${CUDA_PV}-linux-x64-v${MY_PV_MAJOR}.tgz"

SLOT="0/7"
KEYWORDS="~amd64 ~amd64-linux"
RESTRICT="fetch strip"
LICENSE="NVIDIA-cuDNN"

S="${WORKDIR}"

DEPEND="=dev-util/nvidia-cuda-toolkit-${CUDA_PV}*"
RDEPEND="${DEPEND}"

src_install() {
	insinto /usr/$(get_libdir)
	doins -r cuda/lib64/*
	insinto /usr/include
	doins cuda/include/cudnn.h
	dodoc cuda/NVIDIA_SLA_cuDNN_Support.txt
}
