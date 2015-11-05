# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: Colin MacLean
# Purpose: Provides cray module command in Gentoo Prefix
#

if [[ -z ${_CRAYMOD_ECLASS} ]]; then
_CRAYMOD_ECLASS=1 

[ -f /opt/modules/default/init/bash ] && . /opt/modules/default/init/bash

fi
