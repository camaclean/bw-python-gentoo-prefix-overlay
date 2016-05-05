# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="A suite of parallel file system tools designed for performance and scalability"
HOMEPAGE="https://github.com/olcf/pcircle"
if [[ ${PV} == 9999 ]]; then
	inherit git-2
	EGIT_REPO_URI="https://github.com/olcf/pcircle.git"
	SRC_URI=""
else
	SRC_URI="https://github.com/olcf/pcircle/archive/pcircle-v${PV}.zip -> ${P}.tar.gz"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=">=dev-python/scandir-1.1[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pyxattr[${PYTHON_USEDEP}]
	dev-python/lru-dict[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

PYTHON_MODULES="pcircle"

src_prepare() {
	sed -i "s/==/>=/" setup.py
	sed -i "s/xattr>=0.7.8/pyxattr>=0.5.5/" setup.py
	distutils-r1_src_prepare
}
