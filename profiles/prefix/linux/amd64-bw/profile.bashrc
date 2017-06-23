#!/bin/bash
#echo "Bashrc: $PKG_CONFIG_PATH"
#export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$CRAY_PKG_CONFIG_PATHS"
#echo "Bashrc: $PKG_CONFIG_PATH"
if [[ $USER == "" ]]; then
	export USER="user"
fi
#echo "Ebuild phase in profile.bashrc: ${EBUILD_PHASE}"
#echo "$PKG_CONFIG_PATH"
#export PATH=""
#. $EPREFIX/etc/profile
#export PATH="$EPREFIX/usr/lib/portage/bin/ebuild-helpers/unprivileged:$EPREFIX/usr/lib/portage/bin/ebuild-helpers/:$EPREFIX/tmp/usr/lib/portage/bin/ebuild-helpers/unprivileged:$EPREFIX/tmp/usr/lib/portage/bin/ebuild-helpers/:$PATH"
#echo "bashrc PATH: $PATH"
#which aclocal
#echo "$PYTHONPATH"
#echo "${LDP_LDFLAGS}"
#echo $CFLAGS
#echo "bashrc LIBRARY_PATH: $LIBRARY_PATH"

LIBRARY_PATH="$EPREFIX/usr/lib64:$EPREFIX/lib64:$EPREFIX/usr/lib:$EPREFIX/lib:$LIBRARY_PATH"
export LIBRARY_PATH="${LIBRARY_PATH%:}"
CPATH="$EPREFIX/usr/include:$CPATH"
export CPATH="${CPATH%:}"

Pkgenvs=(
	 "sys-devel/gdb addL"
	 "dev-python/numpy-pypy cray"
	 "dev-python/pypy ncurses"
	 "dev-python/pypy3 ncurses"
	 "dev-python/pycdf cray"
	 "sci-libs/arpack cray"
	 "dev-libs/c-blosc cray"
	 "sys-libs/zlib includelocal"
	 "dev-util/cmake ncurses"
	 "sys-libs/readline ncurses"
	 "dev-libs/openssl nolibdirs"
	 "sys-libs/ncurses nolibdirs"
	 "media-libs/libpng nodirs"
	 "dev-lang/python ncurses"
	 "app-shells/bash addL"
	 "dev-lang/tk addL"
	 "sci-physics/harminv pthread"
	 "sci-libs/gsl pthread"
	 "dev-lang/python:2.7 rt"
	 "sci-libs/superlu cray"
         "dev-python/pysparse cray"
	 #"dev-qt/qtcore nohostdirs"
	 #"dev-qt/qtscript simple nohostdirs" 
	 #"dev-qt/qtsql nohostdirs"
	 #"dev-qt/qtxmlpatterns nohostdirs"
	 #"dev-qt/qtgui nohostdirs x11"
	 #"dev-qt/qtsvg nohostdirs"
	 #"dev-qt/qtopengl nohostdirs"
	 #"dev-qt/qtwebkit nohostdirs"
	 #"dev-qt/qtdeclarative nohostdirs x11"
	 #"dev-python/PyQt4 nohostdirs"
	 "dev-python/cvxopt cray"
	 "app-text/openjade addL"
	# "dev-python/pycuda noinc nvidiadrivers"
	 "dev-python/pyopencl nvidiadrivers"
	 "net-dns/c-ares nocinc"
);
	 #"dev-python/mpi4py cray" 


. $PORTAGE_CONFIGROOT/etc/portage/make.profile/versionator.sh

get_version() {
	IFS="-" read -ra comp <<<"$2"
	if [[ ${comp[-1]} == r* ]]; then
		eval "$1=${comp[-2]}-${comp[-1]}"
	else
		eval "$1=${comp[-1]}"
	fi
}

matches_atom() {
	if [[ "${CATEGORY}/${PN}" == "${1}" ]]; then
		return 0
	elif [[ "${CATEGORY}/${PN}:${SLOT}" == "${1}" ]]; then
		return 0
	elif [[ "=${CATEGORY}/${PN}-${PV}" == "${1}" ]]; then
		return 0
	elif [[ "$1" == ">=${CATEGORY}/${PN}-"* ]]; then
		atom_version=''
		get_version atom_version "${1}"
		if  version_is_at_least $atom_version $PVR; then
			return 0
		else
			return 1
		fi
	elif [[ "$1" == ">${CATEGORY}/${PN}-"* ]]; then
		atom_version=''
		get_version atom_version "${1}"
		#If A>B return 3
		if [[ $(version_compare $PVR $atom_version) ==  "3" ]]; then
			return 1
		else
			return 0
		fi
	elif [[ "$1" == "<${CATEGORY}/${PN}-"* ]]; then
		atom_version=''
		get_version atom_version "${1}"
		if  version_is_at_least $atom_version $PVR; then
			return 1
		else
			return 0
		fi
	else
		return 1
	fi
}

if [[ ${EBUILD_PHASE} == unpack || ${EBUILD_PHASE} == install ]]; then
for pkg in "${Pkgenvs[@]}"
do
	pkgarr=($pkg);
	if matches_atom "${pkgarr[0]}"; then
		for env in ${pkgarr[@]:1}
		do
			case $env in
			asneeded)
				export LDFLAGS="-Wl,--as-needed $LDFLAGS"
				;;

			cray)
				export USING_CRAY_ENV="yes"
				export CC=cc
				export CXX=CC
				export F77=ftn
				export FC=ftn
				export F90=ftn
				;;

			crayshared)
				export CRAYPE_LINK_TYPE="dynamic"
				export CC="cc"
				export CXX="CC"
				export F77="ftn"
				export FC="ftn"
				export F90="ftn"
				;;

			crayrpath)
				CRAY_CFLAGS_NOLIBS=$( echo "$CRAY_CFLAGS" | perl -pe 's/-l[\S]+//g and s/[\s]+/ /g')
				export CFLAGS="$CRAY_CFLAGS_NOLIBS $CFLAGS"
				export CXXFLAGS="$CRAY_CFLAGS_NOLIBS $CXXFLAGS"
				export LDFLAGS="$CRAY_RPATH_LDFLAGS $LDFLAGS"
				;;

			pthread)
				export LDFLAGS="-pthread ${LDFLAGS}"
				;;

			includelocal)
				export CFLAGS="-I. ${CFLAGS}"
				export FFLAGS="-I. ${CFLAGS}"
				export CXXFLAGS="-I. ${CXXFLAGS}"
				;;

			ncurses)
				export CFLAGS="${CFLAGS} -I/usr/include/ncurses"
				export FFLAGS="${CFLAGS} -I/usr/include/ncurses"
				export CXXFLAGS="${CXXFLAGS} -I/usr/include/ncurses"
				export LDFLAGS="${LDFLAGS} -I/usr/include/ncures"
				export LDFLAGS="${LDFLAGS} -lncurses"
				;;

			simple)
				export CFLAGS="-O3 -pipe -march=$MARCH"
				export FFLAGS="-O3 -pipe -march=$MARCH"
				export CXXFLAGS="${CFLAGS}"
				;;

			addL)
				save_IFS=$IFS
				IFS=":"
				for l in ${LIBRARY_PATH}; do
					CFLAGS="${CFLAGS} -L$l"
					CXXFLAGS="${CXXFLAGS} -L$l"
				done
				IFS=$save_IFS
				export CFLAGS CXXFLAGS
				;;

			nolibdirs)
				export CFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+//g and s/-l[\S]+//g and s/[\s]+/ /g')
				export FFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+//g and s/-l[\S]+//g and s/[\s]+/ /g')
				export CXXFLAGS=$(echo "$CXXFLAGS" | perl -pe 's/-L[\S]+ //g and s/-l[\S]+//g and s/[\s]+/ /g')
				export LDFLAGS=$(echo "$LDFLAGS" | perl -pe 's/-L[\S]+//g and s/-l[\S]+//g and s/[\s]+/ /g')
				unset LIBRARY_PATH
				;;

			nodirs)
				export CFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+//g; s/-l[\S]+//g; s/-I[\S]+//g; s/[\s]+/ /g')
				export FFLAGS=$(echo "$FFLAGS" | perl -pe 's/-L[\S]+//g; s/-l[\S]+//g; s/-I[\S]+//g; s/[\s]+/ /g')
				export CXXFLAGS=$(echo "$CXXFLAGS" | perl -pe 's/-L[\S]+//g; s/-l[\S]+//g; s/-I[\S]+//g; s/[\s]+/ /g')
				export LDFLAGS=$(echo "$LDFLAGS" | perl -pe 's/-L[\S]+//g; s/-l[\S]+//g; s/-I[\S]+//g; s/[\s]+/ /g')
				unset LIBRARY_PATH
				;;

			nocinc)
				export CFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+//g; s/-l[\S]+//g; s/-I[\S]+//g; s/[\s]+/ /g')
				unset CPATH
				;;

			noinc)
				export CFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+//g; s/-l[\S]+//g; s/-I[\S]+//g; s/[\s]+/ /g')
				export CXXFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+//g; s/-l[\S]+//g; s/-I[\S]+//g; s/[\s]+/ /g')
				unset CPATH
				;;

			addL)
				save_IFS=$IFS
				IFS=":"
				for l in ${LIBRARY_PATH}; do
					CFLAGS="${CFLAGS} -L$l"
					CXXFLAGS="${CXXFLAGS} -L$l"
					LDFLAGS="${LDFLAGS} -L$l"
				done
				IFS=$save_IFS
				export CFLAGS CXXFLAGS LDFLAGS
				;;

			nvidiadrivers)
				export CPATH="/opt/cray/nvidia/default/include:/opt/nvidia/cudatoolkit6.5/default/include:$CPATH"
        			export LDFLAGS="$LDFLAGS -L/opt/cray/nvidia/default/lib64 -Wl,--rpath=/opt/cray/nvidia/default/lib64"
				;;

			nohostdirs)
				export CFLAGS="$(echo "$CFLAGS" | perl -pe 's|-L/usr/lib64||g; s|-L/lib64||g')"
				export CXXFLAGS="$(echo "$CXXFLAGS" | perl -pe 's|-L/usr/lib64||g; s|-L/lib64||g')"
				export FFLAGS="$(echo "$FFLAGS" | perl -pe 's|-L/usr/lib64||g; s|-L/lib64||g')"
				export LDFLAGS="$(echo "$LDFLAGS" | perl -pe 's|-L/usr/lib64||g; s|-L/lib64||g')"
				;;

			nohostinc)
				export CFLAGS=$(echo "$CFLAGS" | perl -pe 's|-I/usr/include||g')
				export CXXFLAGS=$(echo "$CXXFLAGS" | perl -pe 's|-I/usr/include||g')
				export LDFLAGS=$(echo "$LDFLAGS" | perl -pe 's|-I/usr/include||g')
				;;

			x11)
				export CFLAGS="$CFLAGS -I/usr/local/X11R7.7/include/"
				export CXXFLAGS="$CXXFLAGS -I/usr/local/X11R7.7/include/"
				export FFLAGS="$FFLAGS -I/usr/local/X11R7.7/include/"
				export LDFLAGS="$LDFLAGS -L/usr/local/X11R7.7/lib/ -Wl,--rpath=/usr/local/X11R7.7/lib/"
				;;

			craycc)
				export CC=cc
				export CXX=CC
				export FC=ftn
				;;

			rt)
				export LDFLAGS="${LDFLAGS} -lrt"
				;;
			*)
				;;	
			esac
		done
	fi
done
fi

if [ -n "${USING_CRAY_ENV}" ] && [[ ${EBUILD_PHASE} == unpack ]]; then
	export CC=cc
	export CXX=CC
	export F77=ftn
	export FC=ftn
	export F90=ftn
	#export CFLAGS="$CRAY_CFLAGS $CFLAGS"
	#export CXXFLAGS="$CRAY_CFLAGS $CXXFLAGS"
	#export FFLAGS="$CRAY_CFLAGS $FFLAGS"
	#export LDFLAGS="$CRAY_LDFLAGS $LDFLAGS"
fi


if [[ ${EBUILD_PHASE} == unpack ]]; then
	PATHTMP="$(echo $PATH | sed 's|:/usr/bin:/bin||g')"
	ORIG_PATH2="$(echo $ORIG_PATH | sed 's|:/usr/bin:/bin||g')"
	#export PATH="$PATHTMP:$HOST_PATH"
	if [ -z "${ORIG_PATH2}" ]; then
		export PATH="$PATHTMP:/usr/bin:/bin"
	else
		export PATH="$ORIG_PATH2:$PATHTMP:/usr/bin:/bin"
	fi
	unset PATHTMP ORIG_PATH2
	PATH2="$(echo $PATH | sed -e "s|:@sbindir@:|:|" -e "s|:@bindir@:|:|"| perl -pe 's|:[a-zA-Z0-9./_-]+sbin:|:|g')"
	export PATH="$PATH2:${EPREFIX}/usr/sbin:${EPREFIX}/sbin"
	export LDFLAGS="$LDFLAGS $LDP_LDFLAGS"
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
fi

post_src_test() {
	if has savetests ${FEATURES}; then
		einfo "Saving build data for package retesting..."
		STORAGEDIR=${PORTAGE_TESTSTORAGE:-${EPREFIX}/var/lib/portage-tests}/${CATEGORY}/${PF}
		mkdir -p ${STORAGEDIR}
		cp -r ${PORTAGE_BUILDDIR}/* ${STORAGEDIR}
	fi
}

unset PERL5LIB

