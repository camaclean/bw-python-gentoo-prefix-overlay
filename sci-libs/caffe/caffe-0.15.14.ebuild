# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

#EGIT_REPO_URI="git://github.com/BVLC/caffe.git"
#EGIT_REPO_URI="git://github.com/NVIDIA/caffe"
PYTHON_COMPAT=( python2_7 )

DISTUTILS_OPTIONAL=1
inherit toolchain-funcs multilib python-single-r1 cmake-utils cuda

DESCRIPTION="Deep learning framework by the BVLC"
HOMEPAGE="http://caffe.berkeleyvision.org/"
SRC_URI="https://github.com/NVIDIA/caffe/archive/v${PV}.tar.gz -> caffe-${PV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cray cuda docs lmdb leveldb opencv python sm20 sm21 sm30 sm35 sm50"

CDEPEND="
	dev-libs/boost:=[python?]
	dev-libs/protobuf:=[python?]
	dev-cpp/glog:=
	dev-cpp/gflags:=
	sci-libs/hdf5:=
	app-arch/snappy:=
	cuda? ( dev-util/nvidia-cuda-toolkit
		dev-libs/nccl  )
	python? ( ${PYTHON_DEPS} )
	opencv? ( media-libs/opencv:= )
	lmdb? ( dev-db/lmdb:= )
	leveldb? ( dev-libs/leveldb:= )
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
		media-gfx/pydot[${PYTHON_USEDEP}]
		sci-libs/scikits_image[${PYTHON_USEDEP}]
	)
"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	cuda? ( || ( sm20 sm21 sm30 sm35 sm50 ) )
"

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

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${P}.patch
	:
}

src_configure() {
	cuda_sanitize
	if use cray ; then
		CC="${GCC_PATH}/snos/bin/gcc"
		CXX="${GCC_PATH}/snos/bin/g++"
		local mycmakeargs=(
			"-DAtlas_CBLAS_INCLUDE_DIR=$(pc_incdir cblas)"
			"-DAtlas_CLAPACK_INCLUDE_DIR=$(pc_incdir lapack)"
			"-DAtlas_CBLAS_LIBRARY=$(pc_libdir cblas)/lib$(pc_libs cblas).so"
			"-DAtlas_BLAS_LIBRARY=$(pc_libdir blas)/lib$(pc_libs blas).so"
			"-DAtlas_LAPACK_LIBRARY=$(pc_libdir lapack)/lib$(pc_libs lapack).so" 
			"-DCMAKE_CXX_FLAGS=$(portageq envvar CXXFLAGS)"
		)
	fi
	if use python ; then
		mycmakeargs+=(
			"-DBUILD_python=ON"
			"-DBUILD_python_layer=ON"
		)
		if [[ $EPYTHON == python2.? ]] ; then
			mycmakeargs+=( "-Dpython_version=2" )
		elif [[ $EPYTHON == python3.? ]] ; then
			mycmakeargs+=( "-Dpython_version=3" )
		fi
	else
		mycmakeargs+=( 
			"-DBUILD_python=OFF"
			"-DBUILD_python_layer=OFF"
		)
	fi
	if use cuda ; then
		mycmakeargs+=( "-DCPU_ONLY=OFF" )
		local cuda_arches=()
		use sm20 && cuda_arches+=( "20" )
		use sm21 && cuda_arches+=( "21(20)" )
		use sm30 && cuda_arches+=( "30" )
		use sm35 && cuda_arches+=( "35" )
		use sm50 && cuda_arches+=( "50" )
		[ ! -z "${cuda_arches[@]}" ] && mycmakeargs+=(	"-DCUDA_ARCH_NAME=Manual"
								"-DCUDA_ARCH_BIN=\"${cuda_arches[@]}\""
								"-DCUDA_ARCH_PTX=" )
		if use cray ; then
			mycmakeargs+=(
				"-DCUDA_TOOLKIT_ROOT_DIR=$CUDATOOLKIT_HOME"
			#	"-DCUDA_HOST_COMPILER=$(which gcc)"
			)
		fi
	else
		mycmakeargs+=( "-DCPU_ONLY=ON" )
	fi
	
	if use docs ; then
		mycmakeargs+=( "-DBUILD_docs=ON" )
	else
		mycmakeargs+=( "-DBUILD_docs=OFF" )
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

	mycmakeargs+=( "-DBOOST_INCLUDEDIR=\"$(get_eprefix "dev-libs/boost")usr/include/boost\"" )
	
	tc-export CC CXX

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mkdir -p "${ED}"usr/lib/${EPYTHON}/site-packages
	mv "${ED}"usr/python/caffe "${ED}"usr/lib/${EPYTHON}/site-packages || die
	rm -r "${ED}"usr/python || die
}
