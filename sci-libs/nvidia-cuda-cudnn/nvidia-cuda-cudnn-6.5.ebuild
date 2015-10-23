EAPI=5

inherit eutils multilib toolchain-funcs versionator

PKG="cudnn-${PV}-linux-x64-v2"
SRC_URI="${PKG}.tgz"

DESCRIPTION="NVIDIA cuDNN GPU Accelerated Deep Learning"
HOMEPAGE="https://developer.nvidia.com/cuDNN"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
RESTRICT="fetch"

S="${WORKDIR}/${PKG}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - cudnn-${PV}-linux-x64-v2.tgz"
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

src_install() {
	dolib.so libcudnn*$(get_libname)*
	dolib.a libcudnn_static.a

	insinto /usr/include
	doins cudnn.h
}

