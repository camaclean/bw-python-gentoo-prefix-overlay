# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{5,6}} )

inherit toolchain-funcs multilib python-r1 cmake-utils cuda

CMAKE_MAKEFILE_GENERATOR="ninja"
DESCRIPTION="Deep learning framework by the BVLC"
HOMEPAGE="http://caffe.berkeleyvision.org/"
PYBIND11_COMMIT="86e2ad4f77442c3350f9a2476650da6bee253c52"
CNMEM_COMMIT="28a182d49529da49f4ac4e3941cec3edf16b3540"
SRC_URI="https://github.com/caffe2/caffe2/archive/v${PV}.tar.gz -> caffe2-${PV}.tar.gz
https://github.com/NVlabs/cub/archive/v1.7.4.tar.gz -> cub-1.7.4.tar.gz
https://api.github.com/repos/pybind/pybind11/tarball/${PYBIND11_COMMIT} -> pybind11-${PYBIND11_COMMIT:0:7}.tar.gz
https://api.github.com/repos/NVIDIA/cnmem/tarball/${CNMEM_COMMIT} -> cnmem-${PYBIND11_COMMIT:0:7}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE="cray cuda docs lmdb leveldb mpi opencv python"

CDEPEND="
	dev-libs/protobuf:=[python?]
	dev-cpp/glog:=
	dev-cpp/gflags:=
	sci-libs/hdf5:=
	app-arch/snappy:=
	cuda? ( dev-util/nvidia-cuda-toolkit )
	python? ( ${PYTHON_DEPS} )
	opencv? ( media-libs/opencv:= )
	lmdb? ( dev-db/lmdb:= )
	leveldb? ( dev-libs/leveldb:= )
	mpi? ( virtual/mpi )
"
DEPEND="
	${CDEPEND}
	sys-devel/bc
"
RDEPEND="
	${CDEPEND}
	python? (
		dev-python/pandas[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/pydot[${PYTHON_USEDEP}]
		sci-libs/scikits_image[${PYTHON_USEDEP}]
	)
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

PATCHES=( 
	"${FILESDIR}"/caffe2-0.8.0-install-locations.patch
	"${FILESDIR}"/caffe2-0.8.0-libsci.patch
        "${FILESDIR}"/caffe2-0.8.1-nccl2.patch
)

RESTRICT="test"

ENVMOD_REQUIRE="cudatoolkit"

pc_incdir() {
	$(tc-getPKG_CONFIG) --cflags-only-I $@ | \
		sed -e 's/^-I//' -e 's/[ ]*-I/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libdir() {
	$(tc-getPKG_CONFIG) --libs-only-L $@ | \
		sed -e 's/^-L//' -e 's/[ ]*-L/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libs() {
	$(tc-getPKG_CONFIG) --libs-only-l $@ | \
		sed -e 's/[ ]-l*\(pthread\|m\)\([ ]\|$\)//g' \
		-e 's/^-l//' -e 's/[ ]*-l/,/g' -e 's/[ ]*$//' \
		| tr ',' '\n' | sort -u | tr '\n' ',' | sed -e 's|,$||'
}

src_prepare() {
	mv -fT "${WORKDIR}"/cub-1.7.4 ${S}/third_party/cub || die
	mv -fT "${WORKDIR}"/pybind-pybind11-${PYBIND11_COMMIT:0:7} "${S}"/third_party/pybind11 || die
	mv -fT "${WORKDIR}"/NVIDIA-cnmem-${CNMEM_COMMIT:0:7} "${S}"/third_party/cnmem || die
	cmake-utils_src_prepare
}

src_configure() {
	cuda_sanitize
	export CXXFLAGS="${CXXFLAGS} -I$(get_eprefix dev-cpp/eigen:3)/usr/include/eigen3"
	mycmakeargs=( 
		-DUSE_MPI=$(usex mpi)
		-DUSE_GLOO=OFF
		-DBUILD_TEST=OFF
	 )
	if use cray ; then
		#CC="${GCC_PATH}/snos/bin/gcc"
		#CXX="${GCC_PATH}/snos/bin/g++"
		if use mpi; then
			CC=cc
			CXX=CC
			export CRAYPE_LINK_TYPE=dyanmic
			export CRAY_ADD_RPATH=yes
		fi
		mycmakeargs+=(
			-DBLAS=LibSci	
		)
	fi
	if use python ; then
		mycmakeargs+=(
			"-DBUILD_python_layer=ON"
		)
	else
		mycmakeargs+=( 
			"-DBUILD_PYTHON=OFF"
			"-DBUILD_python_layer=OFF"
		)
	fi
	mycmakeargs+=(
		-DBUILD_PYTHON=$(usex python)
		-DUSE_CUDA=$(usex cuda)
	)
	if use cuda ; then
		mycmakeargs+=( "-DUSE_NCCL=ON" )
		mycmakeargs+=( "-DUSE_CNMEM=ON" )
		if use cray ; then
			mycmakeargs+=(
				"-DCUDA_TOOLKIT_ROOT_DIR=$CUDATOOLKIT_HOME"
				"-DCUDA_ARCH_NAME=Kepler"
			)
		fi
	fi
	
	if use docs ; then
		mycmakeargs+=( "-DBUILD_DOCS=ON" )
	else
		mycmakeargs+=( "-DBUILD_DOCS=OFF" )
	fi

	if use lmdb ; then
		mycmakeargs+=( "-DUSE_LMDB=ON" )
	else
		mycmakeargs+=( "-DUSE_LMDB=OFF" )
	fi

	if use leveldb ; then
		mycmakeargs+=( "-DUSE_LEVELDB=ON" )
	else
		mycmakeargs+=( "-DUSE_LEVELDB=OFF" )
	fi

	if use opencv ; then
		mycmakeargs+=( "-DUSE_OPENCV=ON" )
	else
		mycmakeargs+=( "-DUSE_OPENCV=OFF" )
	fi
	
	tc-export CC CXX
	#MY_CMAKE_ARGS=( "${mycmakeargs[@]}" )
	echo "MY_CMAKE_ARGS: ${MY_CMAKE_ARGS[@]}"

	python_foreach_impl cmake-utils_src_configure
}

src_compile() {
	python_foreach_impl cmake-utils_src_compile
}

src_install() {
	python_foreach_impl cmake-utils_src_install
	local i
	for i in $(find "${D}" -name CMakeFiles); do
		rm -rf $i
	done
}
