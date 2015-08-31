#!/bin/bash
#echo "Bashrc: $PKG_CONFIG_PATH"
#export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$CRAY_PKG_CONFIG_PATHS"
#echo "Bashrc: $PKG_CONFIG_PATH"

if [ -n "${USING_CRAY_ENV}" ] && [[ ${EBUILD_PHASE} == unpack ]]; then
	echo "Here Here Here"
	export CFLAGS="$CRAY_CFLAGS $CFLAGS"
	export LDFLAGS="$CRAY_LDFLAGS $LDFLAGS"
fi

if [[ ${EBUILD_PHASE} == unpack ]]; then
	PATHTMP="$(echo $PATH | sed 's|:/usr/bin:/bin||')"
	export PATH="$PATHTMP:$HOST_PATH"
fi
