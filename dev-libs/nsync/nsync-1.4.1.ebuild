# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils toolchain-funcs

DESCRIPTION="nsync is a C library that exports various synchronization primitives, such as mutexes"
HOMEPAGE="https://github.com/google/nsync"
NSYNC_COMMIT="394e71f0ebeed6788ae6c84d42c1bedf6e1ee9f7"
SRC_URI="https://api.github.com/repos/google/nsync/tarball/${NSYNC_COMMIT} -> nsync-${NSYNC_COMMIT:0:7}.tar.gz"

LICENSE="MPL-2.0"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="altivec c++11 cuda debug doc neon openmp test" #zvector vsx
RESTRICT="!test? ( test )"

RDEPEND=""
DEPEND="
"

PATCHES=( "${FILESDIR}"/${PN}-1.4.1-CMakeLists.patch )

src_unpack() {
	default
	mv google* ${P} || die
}

src_configure() {
	local mycmakeargs=( -DNSYNC_LANGUAGE:STRING=c++11 )
	cmake-utils_src_configure
}


