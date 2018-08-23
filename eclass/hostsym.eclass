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
	echo "Linking ${1} to ${ED%/}/${2#/}"
	mkdir -p $(dirname "${D}/${EPREFIX}/${2}")
	ln -nsf "${1}" "${ED%/}/${2#/}" || die "Could not create link"
}

fi

