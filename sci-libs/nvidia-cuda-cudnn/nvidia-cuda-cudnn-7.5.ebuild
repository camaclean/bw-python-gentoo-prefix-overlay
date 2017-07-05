EAPI=5

inherit eutils multilib toolchain-funcs versionator

PKG="cudnn-7.5-linux-x64-v5.1"
SRC_URI="${PKG}.tgz"

DESCRIPTION="NVIDIA cuDNN GPU Accelerated Deep Learning"
HOMEPAGE="https://developer.nvidia.com/cuDNN"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
RESTRICT="fetch"

S="${WORKDIR}/cuda"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PKG}.tgz"
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

src_install() {
	cd lib64
	dolib.so libcudnn*$(get_libname)*
	dolib.a libcudnn_static.a

	cd ../include
	insinto /usr/include
	doins cudnn.h
}

