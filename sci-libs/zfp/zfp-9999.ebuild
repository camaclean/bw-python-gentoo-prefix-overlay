# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

DESCRIPTION="Library for compressed numerical arrays that support high throughput read and write random access"
HOMEPAGE="https://github.com/LLNL/zfp"
if [ ${PV} == 9999 ]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/LLNL/zfp.git"
	#"https://gitlab.kitware.com/third-party/zfp.git"
	SRC_URI=""
else
	SRC_URI="https://github.com/LLNL/zfp/releases/download/${PV}/${P}.tar.gz"
fi

LICENSE="BSD-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_configure()
{
        cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
