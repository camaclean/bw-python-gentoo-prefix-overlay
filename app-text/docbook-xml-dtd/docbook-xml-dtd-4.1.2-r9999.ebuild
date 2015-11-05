# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit sgml-catalog hostsym

MY_P="docbkx412"
DESCRIPTION="Docbook DTD for XML"
HOMEPAGE="http://www.docbook.org/"

LICENSE="docbook"
SLOT="${PV}"
#KEYWORDS="alpha amd64 arm arm64 hppa ia64 m68k ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
KEYWORDS=""
IUSE=""

RDEPEND=">=app-text/docbook-xsl-stylesheets-1.65
	>=app-text/build-docbook-catalog-1.2"
DEPEND=">=app-arch/unzip-5.41"

S=${WORKDIR}

sgml-catalog_cat_include "/etc/sgml/xml-docbook-${PV}.cat" \
	"/etc/sgml/sgml-docbook.cat"
sgml-catalog_cat_include "/etc/sgml/xml-docbook-${PV}.cat" \
	"/usr/share/sgml/docbook/xml-dtd-${PV}/docbook.cat"

src_install() {
	mkdir -p $ED/usr/share/sgml/dcbook
	mkdir -p $ED/etc/sgml
        ln -snf /etc/sgml/sgml-docbook.cat $ED/etc/sgml/sgml-docbook.cat
	dohostdirsym /usr/share/sgml/docbook/xml-dtd-4.1.2
}

pkg_postinst() {
	build-docbook-catalog
	sgml-catalog_pkg_postinst
}

pkg_postrm() {
	build-docbook-catalog
	sgml-catalog_pkg_postrm
}
