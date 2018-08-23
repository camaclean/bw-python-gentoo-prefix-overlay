# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit multilib-build eutils python-r1 distutils-r1 cmake-utils

MY_PV=${PV/_/-}
DESCRIPTION="Open source software library for numerical computation using data flow graphs."
HOMEPAGE="http://www.tensorflow.org/"
SRC_URI="https://github.com/tensorflow/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray cuda graphviz mkl prefix-chaining prefix-chain"

RDEPEND="dev-libs/nccl
	 dev-python/numpy[${PYTHON_USEDEP}]
	 ~dev-python/protobuf-python-3.1.0[${PYTHON_USEDEP}]
	 ~dev-libs/protobuf-3.1.0[${PYTHON_USEDEP}]
         >=sci-libs/scipy-0.15.0[${PYTHON_USEDEP}]
	 dev-python/six[${PYTHON_USEDEP}]
	 $(python_gen_cond_dep 'dev-python/backports-weakref[${PYTHON_USEDEP}]' python2_7)
         cuda? ( !cray? ( dev-util/nvidia-cuda-toolkit ) )
	 graphviz? ( >=dev-python/pydot-1.2.3 )
"
DEPEND="dev-lang/swig
	${RDEPEND}"

PATCHES=( "${FILESDIR}"/tensorflow-${MY_PV}.patch )

S="${WORKDIR}/tensorflow-${MY_PV}"

CMAKE_USE_DIR="${S}"/tensorflow/contrib/cmake/

ENVMOD_REQUIRE="cudatoolkit"

src_prepare() {
	mkdir -p "${S}"/tensorflow/contrib/cmake/patches/eigen || die
	cp "${FILESDIR}"/${P}-Macros.h tensorflow/contrib/cmake/patches/eigen/Macros.h || die
	cmake-utils_src_prepare
}

src_configure() {
	export LDFLAGS_BAK="${LDFLAGS}"
	python_configure() {
		export LDFLAGS="${LDFLAGS_BAK} -Wl,--rpath=${EPREFIX}/usr/lib/${EPYTHON}/site-packages/tensorflow"
	        mkdir -p "${BUILD_DIR}" || die
        	cd "${BUILD_DIR}" || die
		if use cray; then
			CC="${GCC_PATH}/snos/bin/gcc"
			CXX="${GCC_PATH}/snos/bin/g++"
			tc-export CC CXX
		fi
		if use cuda; then
			mycmakeargs=( "-Dtensorflow_ENABLE_GPU=ON" )
			cudnn_prefix=${EPREFIX}
        	        if use prefix-chain; then
				cudnn_prefix="$(get_eprefix sci-libs/nvidia-cuda-cudnn || die)"
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
		mycmakeargs+=( "-Dtensorflow_BUILD_SHARED_LIB=ON" )
	
		cmake-utils_src_configure || die
	}
	python_foreach_impl python_configure
}


src_compile() {
	#export CPATH="/mnt/bwpy/tensorflow/1.3.0/usr/include"
	python_compile() {
		export LDFLAGS="${LDFLAGS_BAK} -Wl,--rpath=${EPREFIX}/usr/lib/${EPYTHON}/site-packages/tensorflow"
		cd "${BUILD_DIR}"
		VERBOSE=1 emake tf_python_package_and_slibs || die
		#VERBOSE=1 emake tensorflow || die
		#VERBOSE=1 emake tf_python_build_pip_package || die
		cd tf_python || die
		esetup.py build || die
	}
	python_foreach_impl python_compile
}

src_install() {
	python_install() {
		cd "${BUILD_DIR}/tf_python" || die
		distutils-r1_python_install
	}
	python_foreach_impl python_install
}

