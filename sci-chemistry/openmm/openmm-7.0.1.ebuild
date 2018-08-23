# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1 cmake-utils

DESCRIPTION="OpenMM: A High Performance Molecular Dynamics Library"
HOMEPAGE="https://github.com/pandegroup/openmm"
SRC_URI="https://github.com/pandegroup/openmm/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray python"

DEPEND=""
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/6.3-python.patch" )

src_prepare() {
	cmake-utils_src_prepare
}

src_configure() {
	
	export OPENMM_CUDA_COMPILER=$CRAY_CUDATOOLKIT_DIR/bin/nvcc
	local mycmakeargs=("-DOPENMM_BUILD_CUDA_LIB=ON"
			   "-DCUDA_CUDA_LIBRARY=/opt/cray/nvidia/default/lib64/libcuda.so"
			  )
	use python && mycmakeargs+=("-DOPENMM_BUILD_PYTHON_WRAPPERS=ON")
	if use cray; then
		export CC=cc
		export CXX=CC
	fi
	cmake-utils_src_configure
}

python_compile() {
	cd python
	echo $(pwd)
	esetup.py build
}

python_install() {
	cd python
	esetup.py install
}

set_openmm_include_path() {
	SUBDIRS=("openmmapi" "olla" "serialization" "plugins/amoeba/openmmapi" "plugins/rpmd/openmmapi" "plugins/drude/openmmapi")
	OPENMM_INCLUDE_PATH="${S}/include;${S}/include/openmm;${S}/include/openmm/internal"
	for subdir in ${SUBDIRS[@]}; do
		OPENMM_INCLUDE_PATH="${OPENMM_INCLUDE_PATH};${S}/${subdir}/include;${S}/${subdir}/include/openmm;${S}/${subdir}/include/openmm/internal"
	done
	export OPENMM_INCLUDE_PATH
}

src_compile() {
	cmake-utils_src_compile
	if use python; then
		python_copy_sources
		build_python() {
			cd "${BUILD_DIR}"/python
			echo "$(pwd)"
			set_openmm_include_path
			export OPENMM_LIB_PATH="${BUILD_DIR}"
			esetup.py build
		}
		python_foreach_impl build_python
	fi
}

src_install() {
	cmake-utils_src_install
	if use python; then
		install_python() {
			cd "${BUILD_DIR}"/python
			echo "$(pwd)"
			esetup.py install --root="${D}"
		}
		python_foreach_impl install_python
	fi
}

