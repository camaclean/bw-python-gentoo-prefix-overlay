# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/coreutils-8.23.ebuild,v 1.1 2014/07/28 09:44:48 vapier Exp $

# To generate the man pages, unpack the upstream tarball and run:
# ./configure --enable-install-program=arch,coreutils
# make
# cd ..
# tar cf - coreutils-*/man/*.[0-9] | xz > coreutils-<ver>-man.tar.xz

EAPI="4"

inherit eutils flag-o-matic toolchain-funcs hostsym

PATCH_VER="1.0"
DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl caps gmp multicall nls selinux static userland_BSD vanilla xattr"

LIB_DEPEND="acl? ( sys-apps/acl[static-libs] )
	caps? ( sys-libs/libcap )
	gmp? ( dev-libs/gmp[static-libs] )
	xattr? ( !userland_BSD? ( sys-apps/attr[static-libs] ) )"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs]} )
	selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )
	!app-misc/realpath
	!<sys-apps/util-linux-2.13
	!sys-apps/stat
	!net-mail/base64
	!sys-apps/mktemp
	!<app-forensics/tct-1.18-r1
	!<net-fs/netatalk-2.0.3-r4
	!<sci-chemistry/ccp4-6.1.1"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )
	app-arch/xz-utils"

S=${WORKDIR}

src_install() {
	local i
	dodir /usr/bin
	for i in /bin/basename /bin/cat /bin/chgrp /bin/chmod /bin/chown /bin/cp /bin/date /bin/dd /bin/df \
		/bin/false /bin/ln /bin/ls /bin/mkdir /bin/mknod /bin/mktemp /bin/mv /bin/pwd /bin/readlink \
		/bin/rm /bin/rmdir /bin/sleep /bin/sort /bin/stty /bin/sync /bin/touch /bin/true /bin/uname \
		/bin/arch /bin/echo
	do
		dohostsym ${i} ${i}
	done
	#ln -nsf /usr/bin/[ $ED/usr/bin/[ || die "Could not create link to /usr/bin/["
	for i in /usr/bin/base64 /usr/bin/basename /usr/bin/chcon /usr/bin/chroot /usr/bin/cksum \
		/usr/bin/comm /usr/bin/csplit /usr/bin/cut /usr/bin/dir /usr/bin/dircolors /usr/bin/dirname \
		/usr/bin/du /usr/bin/env /usr/bin/expand /usr/bin/expr /usr/bin/factor /usr/bin/fmt \
		/usr/bin/fold /usr/bin/head /usr/bin/hostid /usr/bin/id /usr/bin/install /usr/bin/join \
		/usr/bin/link /usr/bin/logname /usr/bin/md5sum /usr/bin/mkfifo /usr/bin/nice /usr/bin/nl \
		/usr/bin/nohup /usr/bin/nproc /usr/bin/od /usr/bin/paste /usr/bin/pathchk /usr/bin/pinky \
		/usr/bin/pr /usr/bin/printenv /usr/bin/printf /usr/bin/ptx /usr/bin/readlink /usr/bin/runcon \
		/usr/bin/seq /usr/bin/sha1sum /usr/bin/sha224sum /usr/bin/sha256sum /usr/bin/sha384sum \
		/usr/bin/sha512sum /usr/bin/shred /usr/bin/shuf /usr/bin/sort /usr/bin/split /usr/bin/stat \
		/usr/bin/stdbuf /usr/bin/sum /usr/bin/tac /usr/bin/tail /usr/bin/tee /usr/bin/test \
		/usr/bin/timeout /usr/bin/touch /usr/bin/tr /usr/bin/truncate /usr/bin/tsort /usr/bin/tty \
		/usr/bin/unexpand /usr/bin/uniq /usr/bin/unlink /usr/bin/users /usr/bin/vdir /usr/bin/wc \
		/usr/bin/who /usr/bin/whoami /usr/bin/yes /usr/bin[ /usr/bin/mkfifo /usr/bin/env /usr/bin/seq \
		/usr/bin/expr /usr/bin/cut /usr/bin/du /usr/bin/dir /usr/bin/dirname /usr/bin/yes /usr/bin/wc \
		/usr/bin/vdir /usr/bin/chroot /usr/bin/head /usr/bin/tail /usr/bin/tty /usr/bin/tr
	do
		dohostsym ${i} ${i}
	done
 	[ -e /usr/bin/numfmt ] && dohostsym /usr/bin/numfmt /usr/bin/numfmt
 	[ -e /usr/bin/realpath ] && dohostsym /usr/bin/realpath /usr/bin/realpath 
}
