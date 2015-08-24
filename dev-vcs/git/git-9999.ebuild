# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

GENTOO_DEPEND_ON_PERL=no

# bug #329479: git-remote-testgit is not multiple-version aware
PYTHON_COMPAT=( python2_7 )

inherit toolchain-funcs eutils elisp-common perl-module bash-completion-r1 python-single-r1 systemd hostsym ${SCM}

MY_PV="${PV/_rc/.rc}"
MY_P="${PN}-${MY_PV}"

DOC_VER=${MY_PV}

DESCRIPTION="GIT - the stupid content tracker, the revision control system heavily used by the Linux kernel team"
HOMEPAGE="http://www.git-scm.com/"
if [[ ${PV} != *9999 ]]; then
	SRC_URI_SUFFIX="xz"
	SRC_URI_GOOG="http://git-core.googlecode.com/files"
	SRC_URI_KORG="mirror://kernel/software/scm/git"
	SRC_URI="${SRC_URI_GOOG}/${MY_P}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_KORG}/${MY_P}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_GOOG}/${PN}-manpages-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_KORG}/${PN}-manpages-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			doc? (
			${SRC_URI_KORG}/${PN}-htmldocs-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			${SRC_URI_GOOG}/${PN}-htmldocs-${DOC_VER}.tar.${SRC_URI_SUFFIX}
			)"
	KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~mips ~ppc ppc64 ~s390 ~sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="+blksha1 +curl cgi doc emacs gnome-keyring +gpg gtk highlight +iconv mediawiki +nls +pcre +perl +python ppcsha1 tk +threads +webdav xinetd cvs subversion test"

# Common to both DEPEND and RDEPEND
CDEPEND="
	dev-libs/openssl:0=
	sys-libs/zlib
	pcre? ( dev-libs/libpcre )
	perl? ( dev-lang/perl:=[-build(-)] )
	tk? ( dev-lang/tk:0= )
	curl? (
		net-misc/curl
		webdav? ( dev-libs/expat )
	)
	emacs? ( virtual/emacs )
	gnome-keyring? ( gnome-base/libgnome-keyring )"

RDEPEND="${CDEPEND}
	gpg? ( app-crypt/gnupg )
	mediawiki? (
		dev-perl/HTML-Tree
		dev-perl/MediaWiki-API
	)
	perl? ( dev-perl/Error
			dev-perl/Net-SMTP-SSL
			dev-perl/Authen-SASL
			cgi? ( dev-perl/CGI highlight? ( app-text/highlight ) )
			cvs? ( >=dev-vcs/cvsps-2.1:0 dev-perl/DBI dev-perl/DBD-SQLite )
			subversion? ( dev-vcs/subversion[-dso,perl] dev-perl/libwww-perl dev-perl/TermReadKey )
			)
	python? ( gtk?
	(
		>=dev-python/pygtk-2.8[${PYTHON_USEDEP}]
		>=dev-python/pygtksourceview-2.10.1-r1:2[${PYTHON_USEDEP}]
	)
		${PYTHON_DEPS} )"

# This is how info docs are created with Git:
#   .txt/asciidoc --(asciidoc)---------> .xml/docbook
#   .xml/docbook  --(docbook2texi.pl)--> .texi
#   .texi         --(makeinfo)---------> .info
DEPEND="${CDEPEND}
	doc? (
		app-text/asciidoc
		app-text/docbook2X
		sys-apps/texinfo
		app-text/xmlto
	)
	nls? ( sys-devel/gettext )
	test? (	app-crypt/gnupg	)"

SITEFILE=50${PN}-gentoo.el
S="${WORKDIR}"

REQUIRED_USE="
	cgi? ( perl )
	cvs? ( perl )
	mediawiki? ( perl )
	subversion? ( perl )
	webdav? ( curl )
	gtk? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )
"

src_install() {
	dohostsyms /usr/bin/diff-highlight /usr/bin/git /usr/bin/git-cvsserver /usr/bin/git-receive-pack \
		/usr/bin/git-shell /usr/bin/git-upload-archive /usr/bin/git-upload-pack /usr/bin/gitview \
		/usr/bin/import-tars
	dohostdirsym /usr/libexec/git-core
}
