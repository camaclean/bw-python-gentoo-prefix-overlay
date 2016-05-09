# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit distutils-r1

DESCRIPTION="Python package to work with Semantic Versioning (http://semver.org/)"
HOMEPAGE="https://github.com/k-bx/python-semver"
SRC_URI="https://github.com/k-bx/python-semver/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE="test"
RDEPEND="test? ( dev-python/nose[${PYTHON_USEDEP}] )
"
DEPEND="${RDEPEND}"

PYTHON_MODULES="semver"

S="${WORKDIR}/python-semver-2.4.1"
