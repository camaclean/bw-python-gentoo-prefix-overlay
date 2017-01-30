# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 python3_4 )

inherit multilib-build eutils python-r1 distutils-r1 cmake-utils

DESCRIPTION="Open source software library for numerical computation using data flow graphs."
HOMEPAGE="http://www.tensorflow.org/"
SRC_URI="https://github.com/tensorflow/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

#SRC_URI=""
#EGIT_REPO_URI="https://github.com/tensorflow/tensorflow.git"
#EGIT_HAS_SUBMODULES="yes"
#if [[ ${PV} != 9999 ]]; then
#	EGIT_COMMIT="v${PV}"
#fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray cuda system-protobuf prefix-chaining"

RDEPEND="dev-python/numpy[${PYTHON_USEDEP}]
         >=dev-python/scipy-0.15.0[${PYTHON_USEDEP}]
	 dev-python/six[${PYTHON_USEDEP}]
         cuda? ( !cray? ( dev-util/nvidia-cuda-toolkit ) )
"
DEPEND="dev-lang/swig
	${RDEPEND}"

PATCHES=( "${FILESDIR}"/tensorflow-0.12.1.patch )

if use cray; then
	ENVMOD_REQUIRE="cudatoolkit"
fi

src_configure() {
	python_configure() {
	        mkdir -p "${BUILD_DIR}" || die
        	cd "${BUILD_DIR}" || die
		if use cray; then
			CC="${GCC_PATH}/snos/bin/gcc"
			CXX="${GCC_PATH}/snos/bin/g++"
			tc-export CC CXX
		fi
		if use cuda; then
			mycmakeargs=( "-Dtensorflow_ENABLE_GPU=ON" )
			cudnn_path="${EPREFIX}"/usr
        	        if use prefix-chaining; then
				cudnn_path="$(get_eprefix sci-libs/nvidia-cuda-cudnn || die)"/usr
			fi
			mycmakeargs+=( "-DCUDNN_HOME=${cudnn_path}" )
			mycmakeargs+=( "-Dtensorflow_CUDA_35=ON" )
			if use cray; then
				mycmakeargs+=( "-Dtensorflow_CUDA_30=OFF" )
				mycmakeargs+=( "-Dtensorflow_CUDA_52=OFF" )
			else
				mycmakeargs+=( "-Dtensorflow_CUDA_30=ON" )
				mycmakeargs+=( "-Dtensorflow_CUDA_52=ON" )
			fi
		fi
	
		CMAKE_USE_DIR="${S}"/tensorflow/contrib/cmake/
		cmake-utils_src_configure || die
	}
	python_foreach_impl python_configure
}


src_compile() {
	python_compile() {
		#MAKEOPTS="-j1"
		cd "${BUILD_DIR}"
		#emake || die
		VERBOSE=1 emake tf_python_build_pip_package || die
		cd tf_python || die
		esetup.py build || die
	}
	python_foreach_impl python_compile
}

src_install() {
	python_install() {
		cd "${BUILD_DIR}" || die
		if use cuda; then
			pip install --no-deps --ignore-installed --prefix="${ED}"/usr tf_python/dist/tensorflow_gpu-${PV}-*.whl
		else
			pip install --no-deps --ignore-installed --prefix="${ED}"/usr tf_python/dist/tensorflow-${PV}-*.whl
		fi
		mkdir -p "${ED}"/usr/lib/python-exec/${EPYTHON}/
		mv "${ED}"/usr/bin/tensorboard "${ED}"/usr/lib/python-exec/${EPYTHON}/tensorboard
	}
	python_foreach_impl python_install
	ln -snf ../lib/python-exec/python-exec2 "${ED}"/usr/bin/tensorflow
}

