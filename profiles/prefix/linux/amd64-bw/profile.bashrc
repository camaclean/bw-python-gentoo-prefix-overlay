#!/bin/bash
#echo "Bashrc: $PKG_CONFIG_PATH"
#export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$CRAY_PKG_CONFIG_PATHS"
#echo "Bashrc: $PKG_CONFIG_PATH"

Pkgenvs=("dev-python/mpi4py cray" 
	 "dev-python/numpy cray"
	 "sys-libs/zlib includelocal"
	 "dev-lang/python ncurses"
	 "dev-util/cmake ncurses"
	 "sys-libs/readline ncurses"
	 "dev-libs/openssl nolibdirs"
	 "sys-libs/ncurses nolibdirs"
	 "media-libs/libpng nodirs"
	 "dev-lang/python:2.7 ncurses rt"
);


. $EPREFIX/etc/portage/make.profile/versionator.sh

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

if [[ ${EBUILD_PHASE} == unpack ]]; then
for pkg in "${Pkgenvs[@]}"
do
	pkgarr=($pkg);
	if matches_atom "${pkgarr[0]}"; then
		for env in ${pkgarr[@]:1}
		do
			echo "$env"
			case $env in
			cray)
				export USING_CRAY_ENV="yes"
				;;

			includelocal)
				CFLAGS="-I. ${CFLAGS}"
				CXXFLAGS="-I. ${CXXFLAGS}"
				;;

			ncurses)
				CFLAGS="${CFLAGS} -I/usr/include/ncurses"
				CXXFLAGS="${CXXFLAGS} -I/usr/include/ncurses"
				LDFLAGS="${LDFLAGS} -I/usr/include/ncures -lncurses"
				;;

			nodirs)
				CFLAGS="-O2 -pipe -march=$MARCH"
				CXXFLAGS="${CFLAGS}"
				;;

			nolibdirs)
				CFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+ //g and s/-l[\S]+//g')
				CXXFLAGS=$(echo "$CXXFLAGS" | perl -pe 's/-L[\S]+ //g and s/-l[\S]+//g')
				LDFLAGS=$(echo "$LDFLAGS" | perl -pe 's/-L[\S]+ //g and s/-l[\S]+//g')
				;;

			nodirs)
				CFLAGS=$(echo "$CFLAGS" | perl -pe 's/-L[\S]+ //g and s/-l[\S]+//g and s/-I[\S]+ //g and s/[\s]+/ /g')
				CXXFLAGS=$(echo "$CXXFLAGS" | perl -pe 's/-L[\S]+ //g and s/-l[\S]+//g and s/-I[\S]+ //g and s/[\s]+/ /g')
				LDFLAGS=$(echo "$LDFLAGS" | perl -pe 's/-L[\S]+ //g and s/-l[\S]+//g and s/-I[\S]+ //g and s/[\s]+/ /g')
				;;

			rt)
				LDFLAGS="${LDFLAGS} -lrt"
				;;

			*)
				;;	
			esac
		done
	fi
done
fi

#if [[ ${CATEGORY}/${PN} == dev-python/mpi4py && ${EBUILD_PHASE} == unpack ]]; then
#	export USING_CRAY_ENV="yes"
#fi

if [ -n "${USING_CRAY_ENV}" ] && [[ ${EBUILD_PHASE} == unpack ]]; then
	export CFLAGS="$CRAY_CFLAGS $CFLAGS"
	export LDFLAGS="$CRAY_LDFLAGS $LDFLAGS"
fi

if [[ ${EBUILD_PHASE} == unpack ]]; then
	PATHTMP="$(echo $PATH | sed 's|:/usr/bin:/bin||')"
	export PATH="$PATHTMP:$HOST_PATH"
	export LDFLAGS="$LDFLAGS $LDP_LDFLAGS"
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
fi
