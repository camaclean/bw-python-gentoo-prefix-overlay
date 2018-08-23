# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MAKEFILE_GENERATOR=ninja
inherit cmake-utils flag-o-matic

DESCRIPTION="gRPC"
HOMEPAGE="https://grpc.io"
GRPC_COMMIT="781fd6f6ea03645a520cd5c675da67ab61f87e4b"
SRC_URI="https://api.github.com/repos/grpc/grpc/tarball/${GRPC_COMMIT} -> ${PN}-1.5.0.tar.gz"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE="cray"
RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/grpc-grpc-${GRPC_COMMIT:0:7}"

src_configure() {
	if use cray; then
		append-cflags -I/usr/include/arpa
		append-cxxflags -I/usr/include/arpa
	fi
	local mycmakeargs=( 
		"-DgRPC_ZLIB_PROVIDER=package" 
		"-DgRPC_CARES_PROVIDER=package"
		"-DgRPC_SSL_PROVIDER=package"
		"-DgRPC_PROTOBUF_PROVIDER=package"
		"-DgRPC_PROTOBUF_PACKAGE_TYPE=MODULE"
		"-DgRPC_GFLAGS_PROVIDER=package"
		"-DgRPC_BENCHMARK_PROVIDER=package"
	)
	cmake-utils_src_configure
}
