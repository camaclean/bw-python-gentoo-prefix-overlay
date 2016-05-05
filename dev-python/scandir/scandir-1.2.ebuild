# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4} )

inherit distutils-r1

DESCRIPTION="Better directory iterator and faster os.walk(), now in the Python 3.5 stdlib"
HOMEPAGE="https://github.com/benhoyt/scandir"
if [[ ${PV} == 9999 ]]; then
	inherit git-2
	EGIT_REPO_URI="https://github.com/benhoyt/scandir.git"
	SRC_URI=""
else
	SRC_URI="https://pypi.python.org/packages/source/s/scandir/scandir-${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_MODULES="scandir"
