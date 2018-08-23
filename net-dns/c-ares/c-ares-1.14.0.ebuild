# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit multilib-minimal cmake-utils

DESCRIPTION="C library that resolves names asynchronously"
HOMEPAGE="http://c-ares.haxx.se/"
SRC_URI="http://${PN}.haxx.se/download/${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc64-solaris"
IUSE="static-libs"

# Subslot = SONAME of libcares.so.2
SLOT="0/2"

DOCS=( AUTHORS CHANGES NEWS README.md RELEASE-NOTES TODO )

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/ares_build.h
)

src_prepare() {
	eapply "${FILESDIR}"/${PN}-1.12.0-remove-tests.patch
	eapply_user
}

multilib_src_configure() {
	local mycmakeargs=(
		-DCARES_STATIC=$(usex static)
		-DCARES_SHARED=ON
	)	
	use static && mycmakeargs+=( -DCARES_STATIC_PIC=ON )
	cmake-utils_src_configure
}

multilib_src_install_all() {
	einstalldocs
}
