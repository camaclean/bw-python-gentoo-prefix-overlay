# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

CMAKE_MAKEFILE_GENERATOR=ninja
inherit git-r3 eutils cmake-utils distutils-r1

MY_PV=${PV/_/-}
DESCRIPTION="Open source software library for numerical computation using data flow graphs."
HOMEPAGE="http://www.tensorflow.org/"
#SRC_URI="https://github.com/tensorflow/tensorflow/archive/v${PV}.tar.gz -> tensorflow-${PV}.tar.gz"
SRC_URI=""
EGIT_REPO_URI="https://github.com/camaclean/tensorflow.git"
EGIT_BRANCH="v${PV}-split"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda mpi"

RDEPEND="dev-libs/nccl
	 ~dev-libs/protobuf-3.6.0.1
	 ~dev-cpp/eigen-tensorflow-${PV}
         ~sci-libs/libtensorflow-${PV}[cuda?]
	 mpi? ( ~sci-libs/libtensorflow-mpi-${PV} )
"
DEPEND="dev-lang/swig
	${RDEPEND}"

#PATCHES=( "${FILESDIR}"/libtensorflow-${MY_PV}.patch )

#S="${WORKDIR}/tensorflow-${MY_PV}"

CMAKE_USE_DIR="${S}"/tensorflow/contrib/cmake_python/

ENVMOD_REQUIRE="cudatoolkit"

src_prepare() {
	#git init .
	#git add .
	#mkdir tensorflow/contrib/cmake_python || die
	#cp "${FILESDIR}"/${P}-CMakeLists.txt tensorflow/contrib/cmake_python/CMakeLists.txt || die
	git remote add myfork git@github.com:camaclean/tensorflow.git
	git fetch myfork
	git branch --set-upstream-to=myfork/v1.10.0-split v1.10.0-split
	cmake-utils_src_prepare
}

src_configure() {
	python_configure() {
	        mkdir -p "${BUILD_DIR}" || die
        	cd "${BUILD_DIR}" || die
		cmake-utils_src_configure || die
	}
	python_foreach_impl python_configure
}

src_compile() {
	#export CPATH="/mnt/bwpy/tensorflow/1.3.0/usr/include"
	python_compile() {
		cd "${BUILD_DIR}" || die
		local mycmakeargs=( 
			-Dtensorflow_ENABLE_GPU=$(usex cuda) 
			-Dtensorflow_ENABLE_MPI=$(usex mpi)
		)
		cmake-utils_src_compile
		#VERBOSE=1 emake tf_python_package_and_slibs || die
		#VERBOSE=1 emake tensorflow || die
		#VERBOSE=1 emake tf_python_build_pip_package || die
		cd tf_python || die
		esetup.py build || die
	}
	python_foreach_impl python_compile
}

src_install() {
	# distutils follows symlinks, installing copies of the binaries. We want to preserve symlinks
	tensorflow_contrib_prefix=$(get_eprefix sci-libs/libtensorflow RDEPEND)
	tensorflow_contrib_libs=(
		libbeam_search_ops.so.${PV}
		libboosted_trees_ops.so.${PV}
		libdistort_image_ops.so.${PV}
		libfactorization_ops.so.${PV}
		libclustering_ops.so.${PV}
		libgru_ops.so.${PV}
		libimage_ops.so.${PV}
		libinput_pipeline_ops.so.${PV}
		liblstm_ops.so.${PV}
		libmemory_stats_ops.so.${PV}
		libnccl_ops.so.${PV}
		libnearest_neighbor_ops.so.${PV}
		libreduce_slice_ops.so.${PV}
		libresampler_ops.so.${PV}
		libsingle_image_random_dot_stereograms.so.${PV}
		libskip_gram_ops.so.${PV}
		libsparse_feature_cross_op.so.${PV}
		libtensor_forest_model_ops.so.${PV}
		libtensor_forest_ops.so.${PV}
		libtensor_forest_stats_ops.so.${PV}
		libtensor_forest_training_ops.so.${PV}
		libtpu_ops.so.${PV}
		libvariable_ops.so.${PV}
		libdataset_ops.so.${PV}
		libcoder_ops.so.${PV}
		libperiodic_resample_op.so.${PV}
	)
	tensorflow_contrib_links=(
		seq2seq/python/ops/_beam_search_ops.so
		boosted_trees/python/ops/_boosted_trees_ops.so
		image/python/ops/_distort_image_ops.so
		factorization/python/ops/_factorization_ops.so
		factorization/python/ops/_clustering_ops.so
		rnn/python/ops/_gru_ops.so
		image/python/ops/_image_ops.so
		input_pipeline/python/ops/_input_pipeline_ops.so
		rnn/python/ops/_lstm_ops.so
		memory_stats/python/ops/_memory_stats_ops.so
		nccl/python/ops/_nccl_ops.so
		nearest_neighbor/python/ops/_nearest_neighbor_ops.so
		reduce_slice_ops/python/ops/_reduce_slice_ops.so
		resampler/python/ops/_resampler_ops.so
		image/python/ops/_single_image_random_dot_stereograms.so
		text/python/ops/_skip_gram_ops.so
		layers/python/ops/_sparse_feature_cross_op.so
		tensor_forest/python/ops/_model_ops.so
		tensor_forest/python/ops/_tensor_forest_ops.so
		tensor_forest/python/ops/_stats_ops.so
		tensor_forest/hybrid/python/ops/_training_ops.so
		tpu/python/ops/_tpu_ops.so
		framework/python/ops/_variable_ops.so
		data/_dataset_ops.so
		coder/python/ops/_coder_ops.so
		periodic_resample/python/ops/_periodic_resample_op.so
	)
	[ ${#tensorflow_contrib_libs[@]} -eq ${#tensorflow_contrib_links[@]} ] || die "Link array sizemismatch! ${#tensorflow_contrib_libs[@]} != ${#tensorflow_contrib_links[@]}"
	python_install() {
		cd "${BUILD_DIR}/tf_python" || die
		distutils-r1_python_install
		local i
		for ((i=0;i<${#tensorflow_contrib_libs[@]};i++)); do
			echo "Linking ${ED}/usr/$(get_libdir)/${EPYTHON}/site-packages/tensorflow/contrib/${tensorflow_contrib_links[$i]} -> ${tensorflow_contrib_prefix%/}/usr/$(get_libdir)/tensorflow/contrib/${tensorflow_contrib_libs[$i]}"
			ln -snf "${tensorflow_contrib_prefix%/}/usr/$(get_libdir)/tensorflow/contrib/${tensorflow_contrib_libs[$i]}" "${ED}/usr/$(get_libdir)/${EPYTHON}/site-packages/tensorflow/contrib/${tensorflow_contrib_links[$i]}" || die
		done
	}
	python_foreach_impl python_install
}
