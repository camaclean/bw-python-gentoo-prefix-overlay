# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="A platform independent file lock."
HOMEPAGE="https://pypi.python.org/pypi/filelock"
SRC_URI="https://pypi.python.org/packages/4f/a2/77c853102454005ff1f95417ae7605b445836212ecd99b717a447c7fb668/${P}.tar.gz -> ${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_MODULES="filelock"

