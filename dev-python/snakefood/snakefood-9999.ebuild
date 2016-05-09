# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4,3_5} )

inherit distutils-r1

if [[ ${PV} == 9999 ]]; then
	inherit mercurial
	EHG_REPO_URI="https://bitbucket.org/blais/snakefood"
	SRC_URI=""
else
	SRC_URI="http://furius.ca/downloads/${PN}/releases/${P}.tar.bz2"
fi

DESCRIPTION="Generate dependency graphs from Python code"
HOMEPAGE="http://furius.ca/snakefood/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="dev-python/six[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}"/${PV}-python3.patch )
