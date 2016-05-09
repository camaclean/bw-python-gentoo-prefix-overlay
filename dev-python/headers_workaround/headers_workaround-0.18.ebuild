# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="Add this to setup_requires, and use it to install headers"
HOMEPAGE="https://pypi.python.org/pypi/headers_workaround"
SRC_URI="https://pypi.python.org/packages/source/h/headers_workaround/${PN}-${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

PYTHON_MODULES="headers_workaround"

