# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="Transcript assembly and differential expression/regulation for RNA-Seq"
HOMEPAGE="http://cufflinks.cbcb.umd.edu/"
SRC_URI="http://cufflinks.cbcb.umd.edu/downloads/${P}.tar.gz"

SLOT="0"
LICENSE="Artistic"
IUSE="debug"
KEYWORDS="~amd64 ~x86"

DEPEND="sci-biology/samtools:0.1-legacy
	>=dev-libs/boost-1.59.0:=
	dev-cpp/eigen:3"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-samtools-legacy.patch
	"${FILESDIR}"/${P}-flags.patch
)

src_prepare() {
	default
	eautoreconf
	append-cppflags $($(tc-getPKG_CONFIG) --cflags eigen3)
}

src_configure() {
	#ifs_bak=$IFS
	#IFS=":"
	#BAM_EPREFIX="${EPREFIX}"
	#local prefix
	#for prefix in ${EPREFIX} ${PORTAGE_READONLY_EPREFIXES}; do
	#	if [ -d "${prefix}/usr/include/bam-0.1-legacy" ]; then
	#		BAM_EPREFIX="${prefix}"
	#		break
	#	fi
	#done
	#
	#BOOST_EPREFIX="${EPREFIX}"
	#for prefix in ${EPREFIX} ${PORTAGE_READONLY_EPREFIXES}; do
	#	if [ -d "${prefix}/usr/include/boost" ]; then
	#		BOOST_EPREFIX="${prefix}"
	#		break
	#	fi
	#done
	#IFS=${ifs_bak}
	BAM_EPREFIX="$(get_eprefix "sci-biology/samtools:0.1-legacy" || die "Could not get the epreifx for samtools" )"
	BOOST_EPREFIX="$(get_eprefix ">=dev-libs/boost-1.59.0:=" || die "Could not get the eprefix for Boost" )"
	econf --disable-optim \
		--with-boost-libdir="${BOOST_EPREFIX}/usr/$(get_libdir)/" \
		--with-bam="${BAM_EPREFIX}/usr/" \
		$(use_enable debug)
}
