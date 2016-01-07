# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit distutils-r1

DESCRIPTION="Lightweight library to build and train neural networks in Theano"
HOMEPAGE="https://github.com/Lasagne/Lasagne"
SRC_URI="https://github.com/Lasagne/Lasagne/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=dev-python/theano-0.8[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

