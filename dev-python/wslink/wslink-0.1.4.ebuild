# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="Python/JavaScript library for communicating over WebSocket"
HOMEPAGE="https://github.com/Kitware/wslink"
SRC_URI="https://github.com/Kitware/wslink/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-3"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"

PYTHON_MODULES="wslink"
S="${S}/python"

