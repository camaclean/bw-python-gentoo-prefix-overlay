# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit python-utils-r1
PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )

inherit python-r1 prefix

DESCRIPTION="Setup python chaining symlinks for python-exec"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

REQUIRED_USE="prefix-chain"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	do_symlinks() {
		local major minor ver prefix f
		python_export PYTHON_PKG_DEP
		prefix="$(get_eprefix "${PYTHON_PKG_DEP}" RDEPEND)"
		prefix=${prefix%/}
		[[ $EPYTHON =~ python([0-9]+)\.([0-9+]) ]] && major=${BASH_REMATCH[1]} && minor=${BASH_REMATCH[2]} && ver="${major}.${minor}"
		mkdir -p ${ED%/}/usr/bin/ || die
		mkdir -p ${ED%/}/usr/lib/python-exec/${EPYTHON} || die
		ln -s ${prefix}/usr/bin/${EPYTHON} ${ED%/}/usr/bin/${EPYTHON} || die
		dosym ${EPREFIX%/}/usr/bin/${EPYTHON} /usr/lib/python-exec/${EPYTHON}/${EPYTHON}
		ln -s ${prefix%/}/usr/bin/${EPYTHON}-config ${ED%/}/usr/bin/${EPYTHON}-config || die
		dosym ${EPREFIX%/}/usr/bin/${EPYTHON}-config /usr/lib/python-exec/${EPYTHON}/${EPYTHON}-config
		if [ -f ${prefix}/usr/bin/pyvenv-$ver ]; then
			ln -s ${prefix%/}/usr/bin/pyvenv-$ver ${ED%/}/usr/bin/pyvenv-$ver || die
			dosym ${EPREFIX%/}/usr/bin/pyvenv-$ver /usr/lib/python-exec/${EPYTHON}/pyvenv-$ver
		fi
		for f in 2to3 idle pydoc; do
			ln -s ${prefix%/}/usr/lib/python-exec/${EPYTHON}/${f} ${ED%/}/usr/lib/python-exec/${EPYTHON}/${f} || die
		done
	}
	python_foreach_impl do_symlinks
}
