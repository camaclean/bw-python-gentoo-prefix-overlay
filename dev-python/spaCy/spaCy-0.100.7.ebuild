# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit distutils-r1

DESCRIPTION="Industrial-strength Natural Language Processing with Python and Cython"
HOMEPAGE="https://github.com/spacy-io/spaCy"
SRC_URI="https://github.com/spacy-io/spaCy/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
RDEPEND="<dev-python/cython-0.24.0[${PYTHON_USEDEP}]
	dev-python/pathlib[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.7[${PYTHON_USEDEP}]
	>=dev-python/cymem-1.30[${PYTHON_USEDEP}]
	<dev-python/cymem-1.32.0[${PYTHON_USEDEP}]
	>=dev-python/preshed-0.46.1[${PYTHON_USEDEP}]
	<dev-python/preshed-0.47.0[${PYTHON_USEDEP}]
	=dev-python/thinc-5.0*[${PYTHON_USEDEP}]
	=dev-python/murmurhash-0.26*[${PYTHON_USEDEP}]
	dev-python/plac[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/ujson[${PYTHON_USEDEP}]
	dev-python/cloudpickle[${PYTHON_USEDEP}]
	>=dev-python/sputnik-0.9.2[${PYTHON_USEDEP}]
	<dev-python/sputnik-0.10.0[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

PYTHON_MODULES="spacy"

