# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4,5} )

inherit distutils-r1

DESCRIPTION="Sputnik: a data package manager library"
HOMEPAGE="https://github.com/spacy-io/sputnik"
SRC_URI="https://github.com/spacy-io/sputnik/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
RDEPEND="dev-python/semver[${PYTHON_USEDEP}]
	dev-python/boto[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}"

PYTHON_MODULES="sputnik"
