# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Chainer: a neural network framework"
HOMEPAGE="https://github.com/pfnet/chainer"
SRC_URI="https://github.com/pfnet/chainer/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""
DEPEND=""
RDEPEND="
dev-python/filelock[${PYTHON_USEDEP}]
dev-python/nose[${PYTHON_USEDEP}]
>=dev-python/numpy-1.9.0[${PYTHON_USEDEP}]
dev-libs/protobuf[python,${PYTHON_USEDEP}]
>=dev-python/six-1.9.0[${PYTHON_USEDEP}]
${DEPEND}"

PYTHON_MODULES="chainer"

src_prepare()
{
	append-ldflags -L/opt/cray/nvidia/default/lib64/ -Wl,--rpath=/opt/cray/nvidia/default/lib64
}
