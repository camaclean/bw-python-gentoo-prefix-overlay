# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_5 )

inherit distutils-r1

DESCRIPTION="Read GSD files with Hoomd"
HOMEPAGE="https://bitbucket.org/glotzer/gsd"
SRC_URI="https://bitbucket.org/glotzer/gsd/get/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"/glotzer-gsd-b659a34e1efe

PYTHON_MODULES="gsd"
