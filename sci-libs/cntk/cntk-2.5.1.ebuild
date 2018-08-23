# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )

inherit toolchain-funcs distutils-r1 cuda

DESCRIPTION="Microsoft Cognative Toolkit"
HOMEPAGE="https://docs.microsoft.com/cognitive-toolkit/"
MULTIVERSO_COMMIT="584eafa164f3f70900d6cd2304413e70ded31efc"
SRC_URI="https://github.com/Microsoft/CNTK/archive/v${PV}.tar.gz -> cntk-${PV}.tar.gz
https://api.github.com/repos/Microsoft/Multiverso/tarball/${MULTIVERSO_COMMIT} -> multiverso-${MULTIVERSO_COMMIT:0:7}.tar.gz
https://github.com/NVlabs/cub/archive/1.7.4.zip -> cub-1.7.4.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE="cray cuda kaldi mkl mpi opencv python zip"

CDEPEND="
	dev-libs/protobuf:=[python?]
	cuda? ( dev-util/nvidia-cuda-toolkit )
	python? ( ${PYTHON_DEPS} )
	opencv? ( media-libs/opencv:= )
	mpi? ( virtual/mpi )
	zip? ( dev-libs/libzip )
	kaldi? ( sci-misc/kaldi )
"
DEPEND="
	${CDEPEND}
"
RDEPEND="
	${CDEPEND}
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

PATCHES=( 
	"${FILESDIR}/cntk-2.5.1.patch"
)

S="${WORKDIR}/CNTK-${PV}"

ENVMOD_REQUIRE="cudatoolkit"

src_prepare() {
	mv -fT "${WORKDIR}/Microsoft-Multiverso-${MULTIVERSO_COMMIT:0:7}" Source/Multiverso || die
	use cray && CXX=$(which CC) || CXX=$(which mpic++)
	sed \
		-e "/cudnn_check=/s:cuda/include/cudnn.h:include/cudnn.h:g" \
		-i configure || die
	sed \
		-e "/CXX = /s:\$(MPI_PATH)/bin/mpic++:${CXX}:g" \
		-e "/SSE_FLAGS = /s:-msse4.1 -mssse3:${CFLAGS}:g" \
		-i Makefile || die
	sed \
		-e "s/GIT_COMMIT=.*/GIT_COMMIT=release/" \
		-e "s/GIT_BRANCH=.*/GIT_BRANCH=${PV}/" \
		-i Tools/generate_build_info || die
	default
	S="${S}/bindings/python" python_copy_sources
}

src_configure() {
	cuda_sanitize
	BUILD_DIR="${WORKDIR}/cntk-build"
	mkdir -p "${BUILD_DIR}" || die
	local conf_opts=()
	if use mkl; then
		conf_opts+=( --with-mkl=/opt/intel/mkl )
	fi
	if use python; then
		conf_opts+=( --with-swig="$(get_eprefix dev-lang/swig DEPEND || die)/usr" )
	fi
	if use cuda; then
		conf_opts+=( --with-cuda="${CUDATOOLKIT_HOME}"
			     --with-gdk-include="$(get_eprefix dev-util/nvidia-cuda-gdk RDEPEND || die)/opt/cuda/gdk/nvml/include" 
			     --with-gdk-nvml-lib="$(get_eprefix dev-util/nvidia-cuda-gdk RDEPEND || die)/opt/cuda/gdk/nvml/lib"
			     --with-cub="${WORKDIR}/cub-1.7.4" 
			     --with-cudnn="$(get_eprefix dev-libs/cudnn RDEPEND)/usr" )
	fi
	if use opencv; then
		conf_opts+=( --with-opencv="$(get_eprefix media-libs/opencv RDEPEND || die)/usr" )
	fi
	if use zip; then
		conf_opts+=( --with-opencv="$(get_eprefix dev-libs/libzip RDEPEND || die)/usr" )
	fi
	if use mpi; then
		if use cray; then
			conf_opts+=( --with-mpi="${CRAY_MPICH_DIR}" )
		else
			conf_opts+=( --with-mpi="$(get_eprefix virtual/mpi RDEPEND || die)/usr" )
		fi
	fi
	echo ./configure \
		--with-build-top="${BUILD_DIR}" \
		--cuda=$(usex cuda) \
		--mpi=$(usex mpi) \
		--python=no \
		--with-boost="$(get_eprefix dev-libs/boost RDEPEND)/usr" \
		--with-protobuf="$(get_eprefix dev-libs/protobuf DEPEND)/usr" \
		"${conf_opts[@]}"
	./configure \
		--with-build-top="${BUILD_DIR}" \
		--cuda=$(usex cuda) \
		--mpi=$(usex mpi) \
		--python=$(usex python) \
		--with-boost="$(get_eprefix dev-libs/boost RDEPEND)/usr" \
		--with-protobuf="$(get_eprefix dev-libs/protobuf DEPEND)/usr" \
		"${conf_opts[@]}" || die
	echo "CNTK_CUDA_CODEGEN_RELEASE=-gencode arch=compute_35,code=\\\"sm_35,compute_35\\\"" >> "${BUILD_DIR}"/Config.make || die
	export CNTK_COMPONENT_VERSION="${PV}"
	export CNTK_VERSION="${PV}"
	export CNTK_VERSION_BANNER="${PV}+"
}

src_compile() {
	cd "${BUILD_DIR}"
	emake
	do_python_build()
	{
		BUILD_DIR="${S}/bindings/python-${EPYTHON/./_}"
		cd "${BUILD_DIR}" || die
		distutils-r1_python_compile
	};
	use python && python_foreach_impl do_python_build
}

src_install() {
	cd "${BUILD_DIR}/lib"
	into /usr
	local i
	for i in *.so; do
		dolib.so $i
	done
	exeinto /usr/bin
	doexe "${BUILD_DIR}"/bin/cntk
	do_python_install()
	{
		BUILD_DIR="${S}/bindings/python-${EPYTHON/./_}"
		cd "${BUILD_DIR}" || die
		distutils-r1_python_install
	};
	use python && python_foreach_impl do_python_install
}
