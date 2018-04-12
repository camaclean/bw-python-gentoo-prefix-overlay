# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{5,6})

inherit distutils-r1 flag-o-matic

DESCRIPTION="Distributed Tensorflow framework using MPI"
HOMEPAGE="https://eng.uber.com/horovod/"
SRC_URI="https://github.com/uber/horovod/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE="cray"
DEPEND=">=dev-python/tensorflow-1.1.0
virtual/mpi
"
RDEPEND="${DEPEND}"

PYTHON_MODULES="horovod"

#src_unpack() {
#	default
#	git init .
#	git add .
#}

src_configure() {
	mkdir third_party
	local eigen_prefix=${EPREFIX}
	use prefix-chain && eigen_prefix="$(get_eprefix ~dev-cpp/eigen-tensorflow-${PV} DEPEND)"
	local tensorflow_prefix=${EPREFIX}
	use prefix-chain && tensorflow_prefix="$(get_eprefix ~sci-libs/libtensorflow-${PV} RDEPEND)"
	append-cflags -I${tensorflow_prefix%/}/usr/include/tensorflow -I${eigen_prefix%/}/usr/include/eigen3-tensorflow
	append-cxxflags -I${tensorflow_prefix%/}/usr/include/tensorflow -I${eigen_prefix%/}/usr/include/eigen3-tensorflow

	if use cray; then
		export CC=cc
		export CXX=CC
		export CRAYPE_LINK_TYPE=dynamic
		export CRAY_ADD_RPATH=yes
		#export HOROVOD_CUDA_INCLUDE="${CUDATOOLKIT_HOME}/include"
		#export HOROVOD_CUDA_LIBS="${CUDATOOLKIT_HOME}/lib64"
		export HOROVOD_MPICXX_SHOW="echo -O2" #"CC --cray-print-opts"
	else
		export CC=mpicc
		export CXX=mpicxx
		export HOROVOD_CUDA_INCLUDE="${EPREFIX}/opt/cuda/include"
		export HOROVOD_CUDA_LIBS="${EPREFIX}/opt/cuda/lib64"
	fi
	#export HOROVOD_GPU_ALLREDUCE="MPI"
	#export HOROVOD_GPU_ALLGATHER="MPI"
	#export HOROVOD_GPU_BROADCAST="MPI"
}
