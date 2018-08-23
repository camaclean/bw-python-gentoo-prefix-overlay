# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="New Globus CLI"
HOMEPAGE="https://www.globus.org"
SRC_URI="https://github.com/globus/globus-cli/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""

#'globus-sdk==0.5.1',
#'click>=6.6,<7.0',
#'configobj>=5.0.6,<6.0.0',
#'requests>=2.0.0,<3.0.0',
#'six>=1.0.0,<2.0.0'

DEPEND="=dev-python/globus-sdk-0.5.1[${PYTHON_USEDEP}]
>=dev-python/configobj-5.0.6[${PYTHON_USEDEP}]
<dev-python/configobj-6.0.0[${PYTHON_USEDEP}]
>=dev-python/click-6.6[${PYTHON_USEDEP}]
<dev-python/click-7.0[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

PYTHON_MODULES="globus-cli"

