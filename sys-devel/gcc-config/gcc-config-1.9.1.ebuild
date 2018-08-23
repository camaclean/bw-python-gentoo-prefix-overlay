# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit toolchain-funcs

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://anongit.gentoo.org/git/proj/gcc-config.git"
	inherit git-r3
else
	SRC_URI="mirror://gentoo/${P}.tar.xz
		https://dev.gentoo.org/~dilfridge/distfiles/${P}.tar.xz"
	KEYWORDS="~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
fi

DESCRIPTION="Utility to manage compilers"
HOMEPAGE="https://gitweb.gentoo.org/proj/gcc-config.git/"
LICENSE="GPL-2"
SLOT="0"
IUSE="cray"

RDEPEND=">=sys-apps/gentoo-functions-0.10"

PATCHES=(
	"${FILESDIR}"/${PN}-1.8-copy-gcc-libs-darwin.patch
	"${FILESDIR}"/${PN}-1.9-cygwin.patch
	"${FILESDIR}"/${PN}-1.9-usrbinenv-bash.patch
)

src_prepare() {
	default
	# Cray uses "cc" as the C MPI compiler wrapper
	use cray && eapply "${FILESDIR}"/${PN}-1.9-no-cc.patch
}

src_compile() {
	emake CC="$(tc-getCC)" \
		EPREFIX="${EPREFIX}" \
		PV="${PV}" \
		SUBLIBDIR="$(get_libdir)"
}

src_install() {
	emake \
		EPREFIX="${EPREFIX}" \
		DESTDIR="${D}" \
		PV="${PV}" \
		SUBLIBDIR="$(get_libdir)" \
		install
}

pkg_postinst() {
	# Scrub eselect-compiler remains
	rm -f "${EROOT}"/etc/env.d/05compiler &

	# We not longer use the /usr/include/g++-v3 hacks, as
	# it is not needed ...
	rm -f "${EROOT}"/usr/include/g++{,-v3} &

	# Do we have a valid multi ver setup ?
	local x
	for x in $(gcc-config -C -l 2>/dev/null | awk '$NF == "*" { print $2 }') ; do
		gcc-config ${x}
	done

	wait
}
