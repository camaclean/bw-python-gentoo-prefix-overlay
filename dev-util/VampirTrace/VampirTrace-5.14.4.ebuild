# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cuda

MY_PV="${PV}-gpu2"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="Library for detailed logging of program execution for parallel applications"
HOMEPAGE="http://tu-dresden.de/die_tu_dresden/zentrale_einrichtungen/zih/forschung/projekte/vampirtrace/accelerator"
SRC_URI="http://wwwpub.zih.tu-dresden.de/~mlieber/dcount/dcount.php?package=gputrace&get=${MY_P}.tar.gz"

SLOT="0"
LICENSE="vampir"
KEYWORDS="~amd64"
IUSE="cray cuda"

S="${WORKDIR}/${MY_P}"

DEPEND="
	virtual/mpi
	cuda? ( >=dev-util/nvidia-cuda-toolkit-4.0.0 )"

src_prepare() {
	use cuda && cuda_src_prepare
}

src_configure() {
	if use cray; then
		module load papi
		export CC=cc
		export CXX=CC
		export FC=ftn
		export CRAYPE_LINK_TYPE=dynamic
		export CRAY_ADD_RPATH=yes
		CPATH="$(get_eprefix dev-util/nvidia-cuda-gdk)/opt/cuda/gdk/nvml/include:${CPATH}"
		export CPATH="${CPATH%:}"
		LIBRARY_PATH="$(get_eprefix dev-util/nvidia-cuda-gdk)/opt/cuda/gdk/nvml/lib:${LIBRARY_PATH}"
		export LIBRARY_PATH="${LIBRARY_PATH%:}"
	fi
	econf $(use_with cuda cuda-dir "${CUDATOOLKIT_HOME:-${EPREFIX}/opt/cuda}")
}

src_install() {
	default
	# avoid collisions with app-text/lcdf-typetools:
	mv "${ED}"/usr/bin/otfinfo{,.vampir} || die
	# libtool is already installed:
	rm "${ED}"/usr/share/libtool || die
}
