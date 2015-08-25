# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Colin MacLean
# Purpose: Provides functions to symlink Gentoo Prefix to host files
#

if [[ -z ${_HOSTSYM_ECLASS} ]]; then
_HOSTSYM_ECLASS=1 

dohostsym() {
	local PATH=$(echo "$PATH:$EHOST_PATH" | sed -e 's|'"$EPREFIX"'[a-zA-Z0-9_/\+\@\.\-]*[:]*||g')

	echo "Linking "$( which $1 )" to ${D}/${EPREFIX}/${2}"
	mkdir -p $(dirname "${D}/${EPREFIX}/${2}")
	ln -nsf "$( which $1 )" "${D}/${EPREFIX}/${2}" || die "Could not create link"
}

dohostsyms() {
	for i in "$@"
	do
		dohostsym $(basename $i) $i
	done
}

dohostoptsym() {
	local PATH=$(echo "$PATH:$EHOST_PATH" | sed -e 's|'"$EPREFIX"'[a-zA-Z0-9_/\+\@\.\-]*[:]*||g')

	echo "Linking "$( which $1 )" to ${D}/${EPREFIX}/${2}"
	mkdir -p $(dirname "${D}/${EPREFIX}/${2}")
	ln -nsf "$( which $1 )" "${D}/${EPREFIX}/${2}"
}

dohostoptsyms() {
	for i in "$@"
	do
		dohostoptsym $(basename $i) $i
	done
}

dohostdirsym() {
	if [ -d ${1} ]; then
		mkdir -p "${D}/${EPREFIX}/$(dirname ${1})" || die
		echo "Linking ${1} to ${D}/${EPREFIX}/${1}"
		ln -snf ${1} ${D}/${EPREFIX}/${1} || die "Could not symlink /usr/share/rsync"
	fi
}

fi

