# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit distutils-r1

DESCRIPTION="Extended pickling support for Python objects"
HOMEPAGE="https://github.com/cloudpipe/cloudpickle"
SRC_URI="https://github.com/cloudpipe/cloudpickle/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"

PYTHON_MODULES="cloudpickle"

