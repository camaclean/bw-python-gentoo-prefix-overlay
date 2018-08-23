# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit cmake-utils python-single-r1

DESCRIPTION="A software that delivers parallel interactive visualizations"
HOMEPAGE="https://wci.llnl.gov/codes/visit/home.html"
SRC_URI="http://portal.nersc.gov/svn/visit/trunk/releases/${PV}/${PN}${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cgns cray debug gdal hdf5 mpi netcdf silo tcmalloc threads xdmf2"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	tcmalloc? ( dev-util/google-perftools )
	cgns? ( sci-libs/cgnslib )
	hdf5? ( sci-libs/hdf5 )
	netcdf? ( sci-libs/netcdf )
	silo? ( sci-libs/silo )
	=sci-libs/vtk-6.1.0*[imaging,mpi=,python,rendering,qt5,xdmf2?,${PYTHON_USEDEP}]
	dev-qt/qtx11extras:5
	sys-libs/zlib
	x11-libs/qwt:6[qt5]"
DEPEND="${RDEPEND}
       xdmf2? ( sci-libs/xdmf2 )
"


S="${WORKDIR}/${PN}${PV}/src"
PATCHES=(
	"${FILESDIR}/${P}-findnetcdfcxx.patch"
	"${FILESDIR}/${P}-findpython.patch"
#	"${FILESDIR}/${P}-findsilo.patch"
	"${FILESDIR}/${P}-findvtk.patch"
	"${FILESDIR}/${P}-vtklibs.patch"
	"${FILESDIR}/${P}-dont_symlink_visit_dir.patch"
	"${FILESDIR}/${P}-cmakelist.patch"
)

src_prepare() {
	for p in ${PATCHES[@]} ; do
		epatch "${p}"
	done
	if use mpi ; then
		epatch "${FILESDIR}/${P}-vtkmpi.patch"
	fi

	sed -i 's/exec python $frontendlauncherpy $0 ${1+"$@"}/exec '${EPYTHON}' $frontendlauncherpy $0 ${1+"$@"}/g' "bin/frontendlauncher"
	sed -i 's/include qwt/include qwt6-qt5/g' CMake/FindQwt.cmake || die
}

src_configure() {
	export CFLAGS="${CFLAGS} -I$(get_eprefix x11-libs/qwt)/usr/include/qwt6 -I$(get_eprefix sci-libs/gdal)/usr/include/gdal/"
	export CXXFLAGS="${CXXFLAGS} -I$(get_eprefix x11-libs/qwt)/usr/include/qwt6 -I$(get_eprefix sci-libs/gdal)/usr/include/gdal/"
	export LDFLAGS="${LDFLAGS} -Wl,--rpath=${EPREFIX}/opt/${PN}/${PV}/linux-$(arch)/lib" # -Wl,--rpath=$(get_eprefix dev-qt/qtcore:4)/usr/lib/qt4"
	if use mpi; then
		#current version doesn't link everything needed
		export LDFLAGS="${LDFLAGS} -Wl,--as-needed ${EPREFIX%/}/usr/lib/libvtkFiltersParallelFlowPaths.so.1 ${EPREFIX%/}/usr/lib/libvtkRenderingFreeTypeFontConfig.so.1 ${EPREFIX%/}/usr/lib/libvtkRenderingMatplotlib.so.1 -Wl,--no-as-needed"
	fi
	if use cray mpi; then
		export CC=cc
		export CXX=CC
		export FC=ftn
		export F77=ftn
	fi
		
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=${EPREFIX}/opt/visit
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_DIR="$(get_eprefix dev-lang/python:2.7 RDEPEND)/usr"
		-DVISIT_PYTHON_SKIP_INSTALL=true
		-DVISIT_VTK_SKIP_INSTALL=true
		-DVISIT_QT5=true
		-DVISIT_QT_DIR="$(get_eprefix dev-qt/qtcore:5)/usr/"
	#	-DQT4_EPREFIX="$(get_eprefix dev-qt/qtcore:4)"
		-DQT_BIN="$(get_eprefix dev-qt/qtcore:5)/usr/bin"
		-DVISIT_ZLIB_DIR="$(get_eprefix sys-libs/zlib)/usr"
		-DVISIT_QWT_DIR="$(get_eprefix x11-libs/qwt)/usr"
		-DVISIT_HEADERS_SKIP_INSTALL=false
		$(cmake-utils_use threads VISIT_THREAD)
	)
	if use hdf5; then
		if use cray; then
			mycmakeargs+=( -DHDF5_DIR="${HDF5_DIR}" )
		else
			mycmakeargs+=( -DHDF5_DIR="${EPREFIX}/usr" )
		fi
	fi
	if use tcmalloc; then
		mycmakeargs+=( -DTCMALLOC_DIR="$(get_eprefix dev-util/google-perftools)/usr" )
	fi
	if use cgns; then
		mycmakeargs+=( -DCGNS_DIR="$(get_eprefix sci-libs/cgnslib)/usr" )
	fi
	if use silo; then
		#mycmakeargs+=( -DSILO_DIR="$(get_eprefix sci-libs/silo)/usr;${HDF5_DIR}" )
		mycmakeargs+=( -DSILO_DIR="$(get_eprefix sci-libs/silo)/usr" )
		#if use cray; then
		#	mycmakeargs+=( -Dhdf5_LIBRARY_DIR="${HDF5_DIR}/lib" )
		#	mycmakeargs+=( -Dhdf5_INCLUDE_DIR="${HDF5_DIR}/include" )
		#fi
	fi
	if use gdal; then
		mycmakeargs+=( -DGDAL_DIR="$(get_eprefix sci-libs/gdal)/usr" )
	fi
	if use netcdf; then
		if use cray; then
			mycmakeargs+=( -DNETCDF_DIR="${NETCDF_DIR}" )
			mycmakeargs+=( -DNETCDF_CXX_DIR="$(get_eprefix sci-libs/netcdf-cxx)/usr" )
		else
			mycmakeargs+=( -DNETCDF_DIR="$(get_eprefix sci-libs/netcdf)/usr" )
		fi
	fi
	if use xdmf2; then
		mycmakeargs+=( -DOPT_VTK_MODS="vtklibxml2" -DVISIT_XDMF_DIR=$(get_eprefix sci-libs/xdmf)/usr/ )
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	PACKAGES_DIR="${ROOT}opt/${PN}/${PV}/linux-$(arch)/lib/site-packages"
	cd "${ED}${PACKAGES_DIR}"
	#dosym includes EPREFIX
	sitedir="$(python_get_sitedir)"
	sitedir=${sitedir##${EPREFIX%/}}
	for i in *; do
		dosym "${PACKAGES_DIR}/${i}" "${sitedir}/$i"
	done

	cat > "${T}"/99visit <<- EOF
		PATH=${EPREFIX}/opt/${PN}/bin
		LDPATH=${EPREFIX}/opt/${PN}/${PV}/linux-$(arch)/lib/
	EOF
	doenvd "${T}"/99visit
}

pkg_postinst () {
	:
	ewarn "Remember to run "
	ewarn "env-update && source /etc/profile"
	ewarn "if you want to use visit in already opened session"
}
