# Copyright 2015 University of Illinois
# Distributed under the terms of the GNU General Public License v3

EAPI=5

inherit eutils 

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DESCRIPTION="Eselect module for Environment Modules"

LICENSE="GPL-3"
SLOT="0"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.4"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_install() {
	insinto /usr/share/eselect/libs/
	newins "${FILESDIR}"/envmod.bash-${PV} envmod.bash
	newins "${FILESDIR}"/envmod-module.bash-${PV} envmod-module.bash
	newins "${FILESDIR}"/envmod-exact.bash-${PV} envmod-exact.bash
	newins "${FILESDIR}"/envmod-fuzzy.bash-${PV} envmod-fuzzy.bash
	newins "${FILESDIR}"/envmod-multi.bash-${PV} envmod-multi.bash
	insinto /usr/share/eselect/modules/
	newins "${FILESDIR}"/envmod.eselect-${PV} envmod.eselect
}
