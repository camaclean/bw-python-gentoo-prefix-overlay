# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MAKEFILE_GENERATOR=ninja
inherit cmake-utils

DESCRIPTION="Protocol Buffers with small code size"
HOMEPAGE="https://github.com/nanopb/nanopb"
NANOPB_COMMIT="14efb1a47a496652ab08b1ebcefb0ea24ae4a5e4"
SRC_URI="https://api.github.com/repos/nanopb/nanopb/tarball/${NANOPB_COMMIT} -> nanopb-${NANOPB_COMMIT:0:7}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}"/nanopb-nanopb-${NANOPB_COMMIT:0:7}

src_configure() {
	export CFLAGS="-fPIC ${CFLAGS}"

	local mycmakeargs=( 
		-Dnanopb_BUILD_GENERATOR=OFF
	)
	cmake-utils_src_configure
}
