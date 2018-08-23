# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit cmake-utils multilib python-r1

MY_P="pyside-setup-everywhere-src-${PV}"

DESCRIPTION="A tool for creating Python bindings for C++ libraries"
HOMEPAGE="http://wiki.qt.io/Qt_for_Python"
SRC_URI="http://download.qt.io/official_releases/QtForPython/pyside2/PySide2-${PV}-src/${MY_P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm ~arm64 ppc ppc64 x86 ~amd64-linux ~x86-linux"

IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/libxml2
	dev-libs/libxslt
	dev-qt/qtcore:5
	dev-qt/qtxmlpatterns:5
"
DEPEND="${RDEPEND}
	test? (
		dev-qt/qtgui:5
		dev-qt/qttest:5
	)"

S="${WORKDIR}/${MY_P}/sources/shiboken2"

src_prepare() {
	if use prefix; then
		cp "${FILESDIR}"/rpath.cmake . || die
		sed -i -e '1iinclude(rpath.cmake)' CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local commoncmakeargs=()
	commoncmakeargs+=( -DCLANG_BUILTIN_INCLUDES_DIR=$(get_eprefix sys-devel/clang RDEPEND)/usr/lib/clang/$(llvm-config --version)/include )
	configuration() {
		local mycmakeargs=(
			${commoncmakeargs[@]}
			$(cmake-utils_use_build test TESTS)
			-DPYTHON_EXECUTABLE="${PYTHON}"
			-DPYTHON_SITE_PACKAGES="$(python_get_sitedir)"
			-DPYTHON_SUFFIX="-${EPYTHON}"
		)

		if [[ ${EPYTHON} == python3* ]]; then
			mycmakeargs+=(
				-DUSE_PYTHON3=ON
				-DPYTHON3_EXECUTABLE="${PYTHON}"
				-DPYTHON3_INCLUDE_DIR="$(python_get_includedir)"
				-DPYTHON3_LIBRARY="$(python_get_library_path)"
			)
		fi

		cmake-utils_src_configure
	}
	python_foreach_impl configuration
}

src_compile() {
	python_foreach_impl cmake-utils_src_compile
}

src_test() {
	python_foreach_impl cmake-utils_src_test
}

src_install() {
	installation() {
		cmake-utils_src_install
		mv "${ED}"usr/$(get_libdir)/pkgconfig/${PN}{,-${EPYTHON}}.pc || die
	}
	python_foreach_impl installation
	dodoc AUTHORS
	cd "${WORKDIR}"/${MY_P} || die
	dodoc CHANGES.rst
	dodoc README.md

}
