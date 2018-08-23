# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit cmake-utils python-single-r1

DESCRIPTION="eXtensible Data Model and Format"
HOMEPAGE="http://xdmf.org/index.php/Main_Page"
SRC_URI="https://dev.gentoo.org/~jlec/distfiles/${P}.tar.gz"

SLOT="0"
LICENSE="VTK"
KEYWORDS="~amd64 ~arm ~x86 ~amd64-linux ~x86-linux"
IUSE="cray doc python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	dev-libs/boost:=
	sci-libs/hdf5:=
	dev-libs/libxml2:2
	python? ( ${PYTHON_DEPS} )
	"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	python? ( dev-lang/swig:0 )
"

PATCHES=(
	"${FILESDIR}"/${P}-cray-mpi.patch
	"${FILESDIR}"/${P}-python-compile.patch
)

S="${WORKDIR}"/Xdmf

pkg_setup() {
	use python && python-single-r1_pkg_setup && python_export
}

src_prepare() {
	if use cray; then
		CC=cc
		CXX=CC
		export CRAYPE_LINK_TYPE="dynamic"
		export CRAY_ADD_RPATH="true"
	fi
	if use python; then
		local _site=$(python_get_sitedir)
		sed \
			-e "/DESTINATION/s:python:${_site##${EPREFIX}/usr/$(get_libdir)/}:g" \
			-i CMakeLists.txt || die
	fi

	sed \
		-e "/DESTINATION/s:lib:$(get_libdir):g" \
		-e "/INSTALL/s:lib:$(get_libdir):g" \
		-i CMakeLists.txt libsrc/CMakeLists.txt || die
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=1
		-DXDMF_BUILD_DOCUMENTATION=$(usex doc)
		-DBUILD_TESTING=$(usex test)
		-DXDMF_WRAP_PYTHON=$(usex python)
		-DMPI_INCLUDE_PATH=""
#		-DXDMF_WRAP_JAVA=$(usex java)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mkdir -p "${ED}"/usr/share/xdmf || die
	mv "${ED}"/usr/lib/XdmfCMake "${ED}"/usr/share/xdmf/cmake || die
	dosym XDMFConfig.cmake /usr/share/xdmf/cmake/XdmfConfig.cmake

	# need to byte-compile 'XdmfCore.py' and 'Xdmf.py'
	# as the CMake build system does not compile them itself
	use python && python_optimize "${D%/}$(python_get_sitedir)"
}
