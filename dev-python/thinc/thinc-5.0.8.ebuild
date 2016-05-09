# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit distutils-r1

DESCRIPTION="thinc: Learn super-sparse multi-class models"
HOMEPAGE="https://github.com/spacy-io/thinc"
SRC_URI="https://github.com/spacy-io/thinc/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
RDEPEND=">=dev-python/numpy-1.7[${PYTHON_USEDEP}]
	=dev-python/murmurhash-0.26*[${PYTHON_USEDEP}]
	>=dev-python/cymem-1.30[${PYTHON_USEDEP}]
	<dev-python/cymem-1.32.0[${PYTHON_USEDEP}]
	=dev-python/preshed-0.46*[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

PYTHON_MODULES="thinc"

