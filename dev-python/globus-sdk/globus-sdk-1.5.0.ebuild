# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="Globus Python SDK"
HOMEPAGE="https://www.globus.org"
SRC_URI="https://github.com/globus/globus-sdk-python/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""

#'requests>=2.0.0,<3.0.0',
#'six>=1.0.0,<2.0.0'

DEPEND="dev-python/six[${PYTHON_USEDEP}]
dev-python/requests[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

PYTHON_MODULES="globus-cli"

S="${WORKDIR}"/globus-sdk-python-${PV}

src_prepare()
{
	rm -rf "${S}"/tests
}

#python_install()
#{
#	distutils-r1_python_install
#}

