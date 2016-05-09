# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="A fast and memory efficient LRU cache for Python"
HOMEPAGE="https://github.com/amitdev/lru-dict"
if [[ ${PV} == 9999 ]]; then
	inherit git-2
	EGIT_REPO_URI="https://github.com/amitdev/lru-dict.git"
	SRC_URI=""
else
	SRC_URI="https://pypi.python.org/packages/source/l/lru-dict/${P}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_MODULES="lru-dict"
