# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="Some of the MurmurHash 2 and 3 hash functions, with a slightly more Pythonic API"
HOMEPAGE="https://pypi.python.org/pypi/murmurhash"
SRC_URI="https://pypi.python.org/packages/source/m/murmurhash/${PN}-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="UNKNOWN"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_MODULES="murmurhash"
