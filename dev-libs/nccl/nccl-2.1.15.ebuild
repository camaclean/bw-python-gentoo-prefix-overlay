# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cuda

DESCRIPTION="Optimized primitives for collective multi-GPU communication"
HOMEPAGE="https://developer.nvidia.com/nccl"

LICENSE="NCCL-SLA"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda80 cuda90 cuda91 +static"

DEPEND="dev-util/nvidia-cuda-toolkit"
RDEPEND="${DEPEND}"
RESTRICT="fetch preserve-libs strip"


SRC_URI="
cuda80? ( nccl_${PV}-1+cuda8.0_x86_64.txz )
cuda90? ( nccl_${PV}-1+cuda9.0_x86_64.txz )
cuda91? ( nccl_${PV}-1+cuda9.1_x86_64.txz )
!cuda80? ( !cuda90? ( !cuda91? (
    nccl_${PV}-1+cuda8.0_x86_64.txz
    nccl_${PV}-1+cuda9.0_x86_64.txz
    nccl_${PV}-1+cuda9.1_x86_64.txz ) ) )
"

S="${WORKDIR}"

cudaversion(){
	local v
	v="$(${CUDATOOLKIT_HOME}/bin/nvcc --version)" 
	if [[ $v =~ .*release\ ([0-9\.]+).* ]]; then
		echo "${BASH_REMATCH[1]}"
	fi
}


pkg_nofetch() {
	einfo "Please download"
	if use cuda80; then
		einfo "  - nccl_${PV}-1+cuda8.0_x86_64.txz"
	elif use cuda90; then
		einfo "  - nccl_${PV}-1+cuda9.0_x86_64.txz"
	elif use cuda91; then
		einfo "  - nccl_${PV}-1+cuda9.1_x86_64.txz"
	else
		einfo "  - nccl_${PV}-1+cuda8.0_x86_64.txz"
		einfo "  - nccl_${PV}-1+cuda9.0_x86_64.txz"
		einfo "  - nccl_${PV}-1+cuda9.1_x86_64.txz"
	fi
		
	einfo "from ${HOMEPAGE} and place them in your DISTDIR directory."
}

src_prepare() {
	S="${WORKDIR}"/nccl_${PV}-1+cuda$(cudaversion)_x86_64
	default
}

src_compile() {
	:
}

src_install() {
	S="${WORKDIR}"/nccl_${PV}-1+cuda$(cudaversion)_x86_64
	insinto /usr/lib
	doins lib/libnccl.so.${PV}
	doins lib/libnccl.so.${PV%%.*}
	doins lib/libnccl.so
	use static && doins lib/libnccl_static.a
	insinto /usr/include
	doins include/nccl.h
}
