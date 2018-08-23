# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="Sparse matrix tools extending scipy.sparse, but with incompatible licenses"
HOMEPAGE="https://github.com/scikit-sparse/scikit-sparse"
SRC_URI="https://github.com/scikit-sparse/scikit-sparse/archive/v${PV}.tar.gz -> scikits_sparse-${PV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/numpy[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/scikit-sparse-${PV}"
