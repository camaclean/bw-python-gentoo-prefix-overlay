# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

MY_PN="M2Crypto"

DESCRIPTION="M2Crypto: A Python crypto and SSL toolkit"
HOMEPAGE="https://gitlab.com/m2crypto/m2crypto https://pypi.python.org/pypi/M2Crypto"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc64"
IUSE="libressl prefix-chain"

RDEPEND="
	!libressl? ( >=dev-libs/openssl-0.9.8:0= )
	libressl? ( dev-libs/libressl:0= )
	dev-python/typing[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	>=dev-lang/swig-1.3.28:0
	dev-python/setuptools[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${MY_PN}-${PV}"

# Tests access network, and fail randomly. Bug #431458.
RESTRICT=test

src_prepare() {
	default
	local ssl_prefix="${EPREFIX}"
	if use prefix-chain; then
		if use libressl; then
			ssl_prefix="$(get_eprefix 'dev-libs/libressl:0=')"
		else
			ssl_prefix="$(get_eprefix '>=dev-libs/openssl-0.9.8:0=')"
		fi
	fi
	sed -i -e "s|self.openssl = '/usr'|self.openssl = '${ssl_prefix%/}/usr'|" setup.py || die
}

python_test() {
	esetup.py test
}
