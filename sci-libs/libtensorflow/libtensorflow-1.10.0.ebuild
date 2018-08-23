# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit git-r3 eutils cmake-utils flag-o-matic

MY_PV=${PV/_/-}
DESCRIPTION="Open source software library for numerical computation using data flow graphs."
HOMEPAGE="http://www.tensorflow.org/"
#SRC_URI="https://github.com/tensorflow/tensorflow/archive/v${PV}.tar.gz -> tensorflow-${PV}.tar.gz"
SRC_URI=""
EGIT_REPO_URI="https://github.com/camaclean/tensorflow.git"
EGIT_BRANCH="v${PV}-split"
#EGIT_MIN_CLONE_TYPE="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray cuda graphviz mkl prefix-chaining prefix-chain"

RDEPEND="dev-libs/nccl[static]
	 ~dev-libs/protobuf-3.1.0
	 >=dev-libs/grpc-1.5.0
	 ~dev-libs/nsync-${PV}
	 ~dev-libs/highwayhash-20160520
	 ~dev-cpp/eigen-tensorflow-${PV}
         cuda? ( !cray? ( dev-util/nvidia-cuda-toolkit ) )
	 graphviz? ( >=dev-python/pydot-1.2.3 )
"
DEPEND="dev-lang/swig
	${RDEPEND}"

#PATCHES=( "${FILESDIR}"/libtensorflow-${MY_PV}.patch )

#S="${WORKDIR}/tensorflow"

CMAKE_USE_DIR="${S}"/tensorflow/contrib/cmake/
CMAKE_MAKEFILE_GENERATOR="emake"

ENVMOD_REQUIRE="cudatoolkit"

src_prepare() {
	#git init .
	#git add .
	#mkdir -p "${S}"/tensorflow/contrib/cmake/patches/eigen || die
	#cp "${FILESDIR}"/${P}-tf_core_mpi.cmake tensorflow/contrib/cmake/tf_core_mpi.cmake || die
	#cp "${FILESDIR}"/${P}-FindLMDB.cmake tensorflow/contrib/cmake/external/FindLMDB.cmake || die
	#cp "${FILESDIR}"/${P}-TensorflowConfig.cmake.in tensorflow/contrib/cmake/TensorflowConfig.cmake.in || die
        #cp "${FILESDIR}"/${P}-cuda_config.h.in tensorflow/contrib/cmake/cuda_config.h.in || die
	git remote add myfork git@github.com:camaclean/tensorflow.git
	git fetch myfork
	git branch --set-upstream-to=myfork/v1.10.0-split v1.10.0-split
	#git fetch
	#git branch --set-upstream-to=myfork/v${PV}-split
	cmake-utils_src_prepare
}

src_configure() {
	if use cray; then
		CC="${GCC_PATH}/snos/bin/gcc"
		CXX="${GCC_PATH}/snos/bin/g++"
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
		mycmakeargs+=( "-Dtensorflow_CUDNN_INCLUDE=${cudnn_prefix%/}/usr/include" )
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
		mycmakeargs+=( "-Dtensorflow_ENABLE_MKL_SUPPORT=ON"
			       "-Dtensorflow_ENABLE_MKLDNN_SUPPORT=ON"
			       "-DMKL_LIBRARIES=/opt/intel/lib/intel64/libiomp5.so;/opt/intel/mkl/lib/intel64/libmkl_rt.so"
                               "-DMKLDNN_LIBRARIES=$(get_eprefix sci-libs/mkl-dnn RDEPEND)/usr/lib/libmkldnn.so"
			       "-DMKL_INCLUDE_DIR=/opt/intel/mkl/include"
		)
		append-ldflags -Wl,--rpath=/opt/intel/mkl/lib/intel64:/opt/intel/lib/intel64
	fi
	mycmakeargs+=( "-Dtensorflow_BUILD_SHARED_LIB=ON" )
	
	cmake-utils_src_configure || die
}

src_install() {
	cmake-utils_src_install
	mkdir -p ${ED}/usr/include/tensorflow/third_party || die
	cp -r "${S}"/third_party/eigen3 "${ED}"/usr/include/tensorflow/third_party/eigen3 || die
	rm "${ED}"/usr/include/tensorflow/third_party/eigen3/BUILD || die
}

