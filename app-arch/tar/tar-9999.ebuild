# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/tar/tar-1.28-r1.ebuild,v 1.2 2015/05/05 06:38:42 vapier Exp $

EAPI=4

inherit flag-o-matic eutils hostsym

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="http://www.gnu.org/software/tar/"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl minimal nls selinux static userland_GNU xattr"

RDEPEND="acl? ( virtual/acl )
	selinux? ( sys-libs/libselinux )"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.10.35 )
	xattr? ( sys-apps/attr )"

S=${WORKDIR}

src_install() {
	dohostsym /bin/tar /bin/tar
}
