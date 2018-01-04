# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MAKEFILE_GENERATOR=ninja
inherit cmake-utils

DESCRIPTION="Protocol Buffers with small code size"
HOMEPAGE="https://github.com/nanopb/nanopb"
PYBIND11_COMMIT="9f6a636e547fc70a02fa48436449aad67080698f"
SRC_URI="https://api.github.com/repos/pybind/pybind11/tarball/${PYBIND11_COMMIT} -> pybind11-${PYBIND11_COMMIT:0:7}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}"/pybind-pybind11-${PYBIND11_COMMIT:0:7}

src_configure() {

	local mycmakeargs=( 
		-DPYBIND11_TEST=OFF
	)
	cmake-utils_src_configure
}
