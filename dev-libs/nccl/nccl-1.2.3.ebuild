# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cuda git-r3

cudaversion(){
	local v
	v="$(nvcc --version)" 
	if [[ $v =~ .*release\ ([0-9\.]+).* ]]; then
		echo "${BASH_REMATCH[1]}"
	fi
}

DESCRIPTION="Optimized primitives for collective multi-GPU communication"
HOMEPAGE="https://github.com/NVIDIA/nccl"
SRC_URI=""
EGIT_REPO_URI="https://github.com/NVIDIA/nccl.git"
cuv="$(cudaversion)"
if [[ ${cuv} == 7.5 ]]; then
	EGIT_COMMIT="v1.2.3-1+cuda7.5"
elif [[ ${cuv} == 8.0 ]]; then
	EGIT_COMMIT="v1.2.3-1+cuda8.0"
else
	die "NCCL requires CUDA 7.5 or 8.0"
fi
unset cuv

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=dev-util/nvidia-cuda-toolkit-7.5.0"
RDEPEND="${DEPEND}"

src_prepare(){
	local cudadir
	[[ $(which nvcc) =~ (.*)/bin/nvcc ]] && cudadir="${BASH_REMATCH[1]}"
	sed -i -e "s:CUDA_HOME ?= /usr/local/cuda:CUDA_HOME ?= ${cudadir:-/opt/cuda}:" -e "s:PREFIX ?= /usr/local:PREFIX ?= ${EPREFIX}/usr:" Makefile
}

src_compile(){
	emake
}
