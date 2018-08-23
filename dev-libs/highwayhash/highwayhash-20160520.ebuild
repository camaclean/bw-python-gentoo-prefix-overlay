# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils toolchain-funcs

DESCRIPTION="Fast strong hash functions: SipHash/HighwayHash"
HOMEPAGE="https://github.com/google/highwayhash"
HIGHWAYHASH_COMMIT="be5edafc2e1a455768e260ccd68ae7317b6690ee"
SRC_URI="https://api.github.com/repos/google/highwayhash/tarball/${HIGHWAYHASH_COMMIT} -> ${P}.tar.gz"

LICENSE="Apache-2"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=""
DEPEND="
"

src_unpack() {
	default
	mv google* ${P} || die
	cp "${FILESDIR}"/CMakeLists-${PV}.txt ${P}/CMakeLists.txt || die
	cp "${FILESDIR}"/highwayhashConfig-${PV}.cmake.in ${P}/highwayhashConfig.cmake.in || die
}

