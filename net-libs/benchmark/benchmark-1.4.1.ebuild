# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit cmake-utils flag-o-matic toolchain-funcs

# should match pinned git submodule version of third_party/protobuf
# look it up here https://github.com/grpc/grpc/tree/v"${PV}"/third_party
# also should ~depend on same version of dev-libs/protobuf below

DESCRIPTION="Modern open source high performance RPC framework"
HOMEPAGE="http://www.grpc.io"
SRC_URI="
	https://github.com/google/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples doc systemtap static-libs tools"

RDEPEND="
	>=dev-libs/openssl-1.0.2:0=[-bindist]
	dev-util/google-perftools
	net-dns/c-ares:=
	sys-libs/zlib:=
"

DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_configure() {
	local mycmakeargs=(
		-DBENCHMARK_ENABLE_GTEST_TESTS=OFF
	)
	cmake-utils_src_configure
}

