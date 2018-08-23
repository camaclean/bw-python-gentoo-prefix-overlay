# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit eutils cmake-utils

MY_PV=${PV/_/-}
DESCRIPTION="Open source software library for numerical computation using data flow graphs."
HOMEPAGE="http://www.tensorflow.org/"
SRC_URI="https://github.com/tensorflow/tensorflow/archive/v${PV}.tar.gz -> tensorflow-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray cuda graphviz mkl prefix-chaining prefix-chain"

RDEPEND="dev-libs/nccl
	 ~dev-libs/protobuf-3.1.0
	 ~sci-libs/libtensorflow-${PV}
	 ~dev-cpp/eigen-tensorflow-${PV}
         cuda? ( !cray? ( dev-util/nvidia-cuda-toolkit ) )
	 graphviz? ( >=dev-python/pydot-1.2.3 )
"
DEPEND="dev-lang/swig
	${RDEPEND}"

PATCHES=( "${FILESDIR}"/libtensorflow-${MY_PV}.patch )

S="${WORKDIR}/tensorflow-${MY_PV}"

CMAKE_USE_DIR="${S}"/tensorflow/contrib/cmake_mpi/

ENVMOD_REQUIRE="cudatoolkit"

src_prepare() {
	git init .
	git add .
	cp "${FILESDIR}"/libtensorflow-${PV}-tf_core_mpi.cmake tensorflow/contrib/cmake/tf_core_mpi.cmake || die
	cp "${FILESDIR}"/libtensorflow-${PV}-FindLMDB.cmake tensorflow/contrib/cmake/external/FindLMDB.cmake || die
	mkdir tensorflow/contrib/cmake_mpi || die
	touch tensorflow/contrib/cmake_mpi/CMakeLists.txt || die
	cp "${FILESDIR}"/${P}-TensorflowMPIConfig.cmake.in tensorflow/contrib/cmake_mpi/TensorflowMPIConfig.cmake.in || die
	cp "${FILESDIR}"/${P}-CMakeLists.txt tensorflow/contrib/cmake_mpi/CMakeLists.txt || die
	#git add -N tensorflow/contrib/cmake_mpi/TensorflowMPIConfig.cmake.in
	#git add -N tensorflow/contrib/cmake_mpi/CMakeLists.txt
	cmake-utils_src_prepare
}

src_configure() {
	if use cray; then
		CC="$(which cc)"
		CXX="$(which CC)"
		tc-export CC CXX
	fi
	if use cuda; then
		mycmakeargs=( "-Dtensorflow_ENABLE_GPU=ON" )
		cudnn_prefix=${EPREFIX}
        	if use prefix-chain; then
			cudnn_prefix="$(get_eprefix dev-libs/cudnn || die)"
		fi
		nccl_prefix=${EPREFIX}
		if use prefix-chain; then
			nccl_prefix="$(get_eprefix dev-libs/nccl || die)"
		fi
		mycmakeargs+=( "-DCUDNN_HOME=${cudnn_prefix%/}/usr" )
		mycmakeargs+=( "-DCUDA_CUDA_LIBRARY=/opt/cray/nvidia/default/lib64/libcuda.so" )
		mycmakeargs+=( "-DNCCL_LIBRARY=${nccl_prefix}/usr/lib/libnccl.so" )
		mycmakeargs+=( "-DNCCL_INCLUDES=${nccl_prefix}/usr/include/nccl.h" )
		mycmakeargs+=( "-Dtensorflow_CUDA_35=ON" )
		if use cray; then
			mycmakeargs+=( "-Dtensorflow_CUDA_30=OFF" )
			mycmakeargs+=( "-Dtensorflow_CUDA_52=OFF" )
		else
			mycmakeargs+=( "-Dtensorflow_CUDA_30=ON" )
			mycmakeargs+=( "-Dtensorflow_CUDA_52=ON" )
		fi
	fi
	if use mkl; then
		mycmakeargs+=( "-Dtensorflow_USE_MKL=ON"
			       "-DMKL_LIBRARIES=/opt/intel/lib/intel64/libiomp5.so;/opt/intel/mkl/lib/intel64/libmkl_rt.so"
			       "-DMKL_INCLUDE_DIR=/opt/intel/mkl/include"
		)
	fi
	mycmakeargs+=( "-DLIBTENSORFLOW_MODULE=OFF" )
	mycmakeargs+=( "-DLIBTENSORFLOW_MPI_MODULE=ON" )
	
	cmake-utils_src_configure || die
}


#src_compile() {
#	cd "${BUILD_DIR}"
#	VERBOSE=1 emake || die
#}

#src_install() {
#	python_install() {
#		cd "${BUILD_DIR}/tf_python" || die
#		distutils-r1_python_install
#	}
#	python_foreach_impl python_install
#}

