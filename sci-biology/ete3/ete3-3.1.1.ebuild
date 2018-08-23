# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="A Python framework for the analysis and visualization of trees"
HOMEPAGE="http://etetoolkit.org"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/ete3-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
RDEPEND=">=dev-python/numpy-1.10.4[${PYTHON_USEDEP}]
        dev-python/six[${PYTHON_USEDEP}]
        dev-python/PyQt5[${PYTHON_USEDEP}]
        dev-python/lxml[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

PYTHON_MODULES="ete3"

#S="${WORKDIR}/ete3-3.0.0b35"
