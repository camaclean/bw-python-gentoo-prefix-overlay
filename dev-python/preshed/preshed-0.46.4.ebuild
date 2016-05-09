# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="Cython Hash Table for Pre-Hashed Keys"
HOMEPAGE="https://github.com/spacy-io/preshed"
SRC_URI="https://github.com/spacy-io/preshed/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
RDEPEND=">=dev-python/cymem-1.30[${PYTHON_USEDEP}]
	<dev-python/cymem-1.32.0[${PYTHON_USEDEP}]
	<dev-python/cython-0.24.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

PYTHON_MODULES="preshed"

