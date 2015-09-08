# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycuda/pycuda-2014.1.ebuild,v 1.1 2014/12/02 11:33:53 jlec Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{3,4} )

inherit distutils-r1 multilib craymodules

DESCRIPTION="Python wrapper for NVIDIA CUDA"
HOMEPAGE="http://mathema.tician.de/software/pycuda/ http://pypi.python.org/pypi/pycuda"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="examples opengl test"

RDEPEND="
	dev-libs/boost[python,${PYTHON_USEDEP}]
	dev-python/decorator[${PYTHON_USEDEP}]
	dev-python/mako[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/pytools-2013[${PYTHON_USEDEP}]
	dev-util/nvidia-cuda-toolkit
	x11-drivers/nvidia-drivers
	opengl? ( virtual/opengl )"
DEPEND="${RDEPEND}
	test? (
		dev-python/mako[${PYTHON_USEDEP}]
		dev-python/pytest[${PYTHON_USEDEP}] )"

# We need write acccess /dev/nvidia0 and /dev/nvidiactl and the portage
# user is (usually) not in the video group
RESTRICT="userpriv"

cuda_sanitize() {
	echo "$PATH"
	local rawldflags=$(raw-ldflags)
	# Be verbose if wanted
	[[ "${CUDA_VERBOSE}" == true ]] && NVCCFLAGS+=" -v"

	# Tell nvcc where to find a compatible compiler
	NVCCFLAGS+=" --compiler-bindir=$CRAY_CUDATOOLKIT_DIR/bin"

	# Tell nvcc which flags should be used for underlying C compiler
	NVCCFLAGS+=" --compiler-options=\"${CXXFLAGS}\" --linker-options=\"${rawldflags// /,},-L/opt/cray/nvidia/default/lib64,--rpath=/opt/cray/nvidia/default/lib64\""

	debug-print "Using ${NVCCFLAGS} for cuda"
	export NVCCFLAGS
}

pkg_setup() {
	module load cudatoolkit
}

pkg_install() {
	module unload cudatoolkit
}

python_prepare_all() {
	cuda_sanitize
	sed \
		-e "s:'--preprocess':\'--preprocess\', \'--compiler-bindir=$CRAY_CUDATOOLKIT_DIR/bin\':g" \
		-e "s:\"--cubin\":\'--cubin\', \'--compiler-bindir=$CRAY_CUDATOOLKIT_DIR/bin\':g" \
		-e "s:/usr/include/pycuda:${S}/src/cuda:g" \
		-i pycuda/compiler.py || die

	touch siteconf.py || die

	distutils-r1_python_prepare_all
}

python_configure() {
	local myopts=()
	use opengl && myopts+=( --cuda-enable-gl )

        export LDFLAGS="$LDFLAGS -L/opt/cray/nvidia/default/lib64 -Wl,--rpath=/opt/cray/nvidia/default/lib64"
	mkdir "${BUILD_DIR}" || die
	cd "${BUILD_DIR}" || die
	[[ -e ./siteconf.py ]] && rm -f ./siteconf.py
	"${EPYTHON}" "${S}"/configure.py \
		--boost-inc-dir="${EPREFIX}/usr/include" \
		--boost-lib-dir="${EPREFIX}/usr/$(get_libdir)" \
		--boost-python-libname=boost_python-$(echo ${EPYTHON} | sed 's/python//')-mt \
		--boost-thread-libname=boost_thread-mt \
		--cuda-root="$CRAY_CUDATOOLKIT_DIR" \
		--cudadrv-lib-dir="${EPREFIX}/usr/$(get_libdir)" \
		--cudart-lib-dir="$CRAY_CUDATOOLKIT_DIR/lib64" \
		--cuda-inc-dir="$CRAY_CUDATOOLKIT_DIR/include" \
		--no-use-shipped-boost \
		"${myopts[@]}"
}

src_test() {
	# we need write access to this to run the tests
	addwrite /dev/nvidia0
	addwrite /dev/nvidiactl
	python_test() {
			py.test --debug -v -v -v || die "Tests fail with ${EPYTHON}"
	}
	distutils-r1_src_test
}

python_install_all() {
	distutils-r1_python_install_all

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
