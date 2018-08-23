# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_5} )
#CMAKE_MAKEFILE_GENERATOR="ninja"

inherit cmake-utils cuda python-r1

DESCRIPTION="a general-purpose particle simulation toolkit"
HOMEPAGE="http://codeblue.umich.edu/hoomd-blue/"
EGIT_REPO_URI="https://bitbucket.org/glotzer/${PN}.git"

if [[ ${PV} = 9999 ]]; then
	EGIT_REPO_URI="https://bitbucket.org/glotzer/${PN}.git"
	inherit git-r3
else
	inherit vcs-snapshot
	GETTAR_VER=0.5.3
	CEREAL_VER=1.2.2
	PYBIND11_VER=1.8.1
	CUB_VER=1.6.4
	NSL_VER=9999
	UPP11_VER=3.0
	QUICKHULL_COMMIT=22bc4e7012788c2cbc381f17cc1d6c370770ecd7
	SRC_URI="https://bitbucket.org/glotzer/${PN}/get/v${PV}.tar.bz2 -> ${P}.tar.bz2
		https://bitbucket.org/glotzer/libgetar/get/v${GETTAR_VER}.tar.bz2 -> libgetar-${GETTAR_VER}.tar.bz2
                https://github.com/USCiLab/cereal/archive/v${CEREAL_VER}.tar.gz -> cereal-${CEREAL_VER}.tar.gz
                https://github.com/pybind/pybind11/archive/v${PYBIND11_VER}.tar.gz -> pybind11-${PYBIND11_VER}.tar.gz
		https://github.com/NoAvailableAlias/nano-signal-slot/archive/34223a4a7e97f8e114ef007e5360cf7a71265da3.tar.gz -> nano-signal-slot-${NSL_VER}.tar.gz
		https://github.com/NVlabs/cub/archive/v${CUB_VER}.tar.gz -> cub-${CUB_VER}.tar.gz
		https://github.com/glotzerlab/upp11/archive/v${UPP11_VER}.tar.gz -> upp11-${UPP11_VER}.tar.gz
		https://api.github.com/repos/glotzerlab/quickhull/tarball/${QUICKHULL_COMMIT} -> quickhull-${QUICKHULL_COMMIT:0:7}.tar.gz
	"
	KEYWORDS="~amd64"
fi

LICENSE="hoomd-blue"
SLOT="0"
IUSE="acml cuda test mpi cray"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	mpi? ( virtual/mpi )
	cuda? ( dev-util/nvidia-cuda-sdk )
	dev-libs/boost:=[threads,python,mpi?,${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

src_prepare() {
	[[ ${PV} = 9999 ]] || mv -fT ../libgetar-${GETTAR_VER} hoomd/extern/libgetar || die
	[[ ${PV} = 9999 ]] || mv -fT ../cereal-${CEREAL_VER} hoomd/extern/cereal || die
	[[ ${PV} = 9999 ]] || mv -fT ../pybind11-${PYBIND11_VER} hoomd/extern/pybind || die
	[[ ${PV} = 9999 ]] || mv -fT ../nano-signal-slot-${NSL_VER} hoomd/extern/nano-signal-slot || die
	[[ ${PV} = 9999 ]] || mv -fT ../cub-${CUB_VER} hoomd/extern/cub || die
	[[ ${PV} = 9999 ]] || mv -fT ../upp11-${UPP11_VER} hoomd/extern/upp11 || die
	[[ ${PV} = 9999 ]] || mv -fT ../quickhull-${QUICKHULL_COMMIT:0:7} hoomd/extern/quickhull || die
	use cuda && cuda_src_prepare
	cmake-utils_src_prepare
}

src_configure() {
	export ENVMOD="acml"
	use cuda && cuda_sanitize
	if use cray; then
		if use acml; then
			#module load acml
			export LDFLAGS="${LDFLAGS} -Wl,--rpath=${ACML_BASE_DIR}/gfortran64_fma4/lib"
		fi
		
	fi
	if use mpi; then
		if use cray; then
			export CRAYPE_LINK_TYPE="dynamic"
			export CRAY_ADD_RPATH="yes"
			CC="$(which cc)"
			CXX="$(which CC)"
			export MPI_C="$(which cc)"
			export MPI_CXX="$(which CC)"
		else
			CC="mpicc"
			CXX="mpicxx"
		fi
	fi
	src_configure_internal() {
		local mycmakeargs=(
			-DENABLE_MPI=$(usex mpi)
			-DENABLE_CUDA=$(usex cuda)
			-DBUILD_TESTING=$(usex test)
			-DUPDATE_SUBMODULES=OFF
			-DPYTHON_EXECUTABLE="${PYTHON}"
			-DCMAKE_INSTALL_PREFIX=$(python_get_sitedir)
		)
		if use cray; then
			mycmakeargs+=(
				-DMPIEXEC="aprun" 
				-DMPIEXEC_NUMPROC_FLAG="-n"
				-DCUDA_ARCH_LIST="35"
				-DBUILD_CGCMM=ON
				-DBUILD_DEM=ON
				-DBUILD_DEPRECATED=ON
				-DBUILD_HPMC=ON
				-DBUILD_METAL=ON
				-DBUILD_MD=ON
				-DCUDA_HOST_COMPILER="$(which x86_64-pc-linux-gnu-gcc)"
	#			-DMPI_CUDA=ON
	#			-DENABLE_MPI_CUDA=ON
			)
		fi
		#use mpi cuda && mycmakeargs+=( -DCUDA_USE_STATIC_CUDA_RUNTIME=OFF ) 
		use cray acml && mycmakeargs+=( -DACML_INCLUDES="${ACML_BASE_DIR}"/gfortran64_fma4/include )
		use acml && mycmakeargs+=( -DACML_LIBRARIES="${ACML_BASE_DIR}/gfortran64_fam4/lib/libacml.so" )
		use cray && mycmakeargs+=( -DSQLITE3_INCLUDE_DIRS="$(pkg-config --cflags-only-I sqlite3 | sed -e "s/-I//g" -e "s/ /:/g")" -DSQLITE3_LIBRARIES="-lsqlite3")
		cmake-utils_src_configure
	}
	python_foreach_impl src_configure_internal
}

src_compile() {
	python_foreach_impl cmake-utils_src_make
}

src_test() {
	python_foreach_impl cmake-utils_src_test
}

src_install() {
	python_foreach_impl cmake-utils_src_install
}
