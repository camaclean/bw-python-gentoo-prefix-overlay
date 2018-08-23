# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit toolchain-funcs cmake-utils

CMAKE_MAKEFILE_GENERATOR="ninja"
DESCRIPTION="Intel(R) Math Kernel Library for Deep Neural Networks (Intel(R) MKL-DNN)"
HOMEPAGE="https://01.org/mkl-dnn"
SRC_URI="https://github.com/intel/mkl-dnn/archive/v${PV}.tar.gz -> mkl-dnn-${PV}.tar.gz"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 x86 ~amd64-linux ~x86-linux ~x86-macos"
IUSE="cray"

DEPEND="
"
RDEPEND="
"

PATCHES=( "${FILESDIR}"/${PN}-0.16-amd.patch )

src_configure()
{
	local mycmakeargs=( -DMKLROOT=/opt/intel/mkl -DMKLLIBPATH=/opt/intel/mkl/lib/intel64 )
	local LDFLAGS="${LDFLAGS} -Wl,-rpath=/opt/intel/mkl/lib/intel64 -Wl,-rpath=/opt/intel/lib/intel64"
	cmake-utils_src_configure
}
