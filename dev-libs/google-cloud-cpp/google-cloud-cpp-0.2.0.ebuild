# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
CMAKE_MAKEFILE_GENERATOR=ninja
inherit cmake-utils

DESCRIPTION="Google Cloud Client Library for C++"
HOMEPAGE=" https://cloud.google.com/"
GOOGLEAPIS_TAG="6a3277c0656219174ff7c345f31fb20a90b30b97"
SRC_URI="https://github.com/GoogleCloudPlatform/google-cloud-cpp/archive/v${PV}.tar.gz -> ${P}.tar.gz
https://github.com/googleapis/googleapis/archive/${GOOGLEAPIS_TAG}.tar.gz -> googleapis-${GOOGLEAPIS_TAG:0:7}.tar.gz
"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64 ~amd64-linux"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	default
	mv -fT googleapis-${GOOGLEAPIS_TAG} "${S}"/third_party/googleapis || die
}

src_prepare() {
	cmake-utils_src_prepare
	git init .
	git add .
}

src_configure() {
	local mycmakeargs=( 
		-DGOOGLE_CLOUD_CPP_GMOCK_PROVIDER=package
		-DGOOGLE_CLOUD_CPP_GRPC_PROVIDER=package
		-DBUILD_SHARED_LIBS=ON
	)
	cmake-utils_src_configure
}
