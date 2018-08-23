# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit prefix

DESCRIPTION="Chained EPREFIX bootstrapping utility"
HOMEPAGE="https://prefix.gentoo.org/"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="cray"

DEPEND="sys-apps/portage[prefix-chaining]"
RDEPEND=""

S="${WORKDIR}"

src_install() {
	if use cray; then
		DOMODULE="yes"
	fi
	eprefixify ${PN}
	sed -i -e "s/@GENTOO_PORTAGE_CHOST@/${CHOST}/" -e "s/@DOMODULE@/${DOMODULE}/" ${PN}
	dobin ${PN}
	insinto /usr/share/prefix-chaining
	doins "${FILESDIR}"/modulefile.in
}

src_unpack() {
	{ cat > "${PN}" || die; } <<'EOF'
#!/usr/bin/env bash

PARENT_EPREFIX="@GENTOO_PORTAGE_EPREFIX@"
PARENT_CHOST="@GENTOO_PORTAGE_CHOST@"
CHILD_EPREFIX=
CHILD_PROFILE=
DO_MINIMAL=no
DO_SOURCES=no
PORT_TMPDIR=

trap 'exit 1' TERM KILL INT QUIT ABRT

#
# get ourselfs the functions.sh script for ebegin/eend/etc.
#
. "${PARENT_EPREFIX}"/lib/gentoo/functions.sh

export PORTAGE_TMPDIR="/dev/shm/$USER/chainsetup"
mkdir -p $PORTAGE_TMPDIR

for arg in "$@"; do
	case "${arg}" in
	--eprefix=*)	CHILD_EPREFIX="${arg#--eprefix=}"	;;
	--profile=*)	CHILD_PROFILE="${arg#--profile=}"	;;
	--sources)		DO_SOURCES=yes						;;
	--user)		INSTALL_MODULEFILE=no ;;
#	--portage-tmpdir=*)	PORT_TMPDIR="${arg#--portage-tmpdir=}" ;;

	--help)
		einfo "$0 usage:"
		einfo "  --eprefix=[PATH]       Path to new EPREFIX to create chained to the prefix"
		einfo "                         where this script is installed (${PARENT_EPREFIX})"
		einfo "  --profile=[PATH]       The absolute path to the profile to use. This path"
		einfo "                         must point to a directory within ${PARENT_EPREFIX}"
		einfo "  --sources              inherit 'source' statements from the parent make.conf"
	#	einfo "  --portage-tmpdir=DIR   use DIR as portage temporary directory."
		exit 0
		;;
	esac
done

#
# sanity check of given values
#

test -n "${CHILD_EPREFIX}" || { eerror "no eprefix argument given"; exit 1; }
test -d "${CHILD_EPREFIX}" && { eerror "${CHILD_EPREFIX} already exists"; exit 1; }
test -n "${CHILD_PROFILE}" || { eerror "no profile argument given"; exit 1; }
test -d "${CHILD_PROFILE}" || { eerror "${CHILD_PROFILE} does not exist"; exit 1; }
if test -n "${PORT_TMPDIR}"; then
	if ! test -d "${PORT_TMPDIR}"; then
		einfo "creating temporary directory ${PORT_TMPDIR}"
		mkdir -p "${PORT_TMPDIR}"
	fi
fi

einfo "creating chained prefix ${CHILD_EPREFIX}"

#
# functions needed below.
#
eend_exit() {
	eend $1
	[[ $1 != 0 ]] && exit 1
}

#
# create the directories required to bootstrap the least.
#
ebegin "creating directory structure"
(
	set -e
	mkdir -p "${CHILD_EPREFIX}"/etc/env.d
	mkdir -p "${CHILD_EPREFIX}"/usr/portage/distfiles
	mkdir -p "${CHILD_EPREFIX}"/etc/portage/profile/use.mask
	mkdir -p "${CHILD_EPREFIX}"/etc/portage/profile/use.force
	mkdir -p "${CHILD_EPREFIX}"/var/log
	mkdir -p "${CHILD_EPREFIX}"/usr/lib/portage
	touch "${CHILD_EPREFIX}"/usr/lib/portage/.portage_not_installed
	mkdir -p "${CHILD_EPREFIX}"/var/cache/eix
	mkdir -p "${CHILD_EPREFIX}"/usr/lib
	mkdir -p "${CHILD_EPREFIX}"/lib
	ln -snf lib "${CHILD_EPREFIX}"/usr/lib64
	ln -snf lib "${CHILD_EPREFIX}"/lib64
)
eend_exit $?

#
# create a make.conf and set PORTDIR and PORTAGE_TMPDIR
#
ebegin "creating make.conf"
(
	set -e
	echo "#"
	echo "# The following values where taken from the parent prefix's"
	echo "# environment. Feel free to adopt them as you like."
	echo "#"
	echo "CFLAGS=\"$(EPREFIX=${PARENT_EPREFIX} ${PARENT_EPREFIX}/usr/bin/portageq envvar CFLAGS)\""
	echo "CXXFLAGS=\"$(EPREFIX=${PARENT_EPREFIX} ${PARENT_EPREFIX}/usr/bin/portageq envvar CXXFLAGS)\""
	echo "FFLAGS=\"$(EPREFIX=${PARENT_EPREFIX} ${PARENT_EPREFIX}/usr/bin/portageq envvar FFLAGS)\""
	echo "MAKEOPTS=\"$(EPREFIX=${PARENT_EPREFIX} ${PARENT_EPREFIX}/usr/bin/portageq envvar MAKEOPTS)\""
	echo "LDFLAGS=\"-Wl,--rpath=${CHILD_EPREFIX}/usr/lib -Wl,--rpath=${CHILD_EPREFIX}/lib $(EPREFIX=${PARENT_EPREFIX} ${PARENT_EPREFIX}/usr/bin/portageq envvar LDFLAGS)\""
	niceness=$(EPREFIX=${PARENT_EPREFIX} ${PARENT_EPREFIX}/usr/bin/portageq envvar PORTAGE_NICENESS)
	[[ -n ${niceness} ]] &&
		echo "PORTAGE_NICENESS=\"${niceness}\""
	echo "USE=\"$(. ${PARENT_EPREFIX}/etc/portage/make.conf && echo $USE) prefix-chain\""
	echo
	echo "# Mirrors from parent prefix."
	echo "GENTOO_MIRRORS=\"$(EPREFIX=${PARENT_EPREFIX} ${PARENT_EPREFIX}/usr/bin/portageq envvar GENTOO_MIRRORS || true)\""
	echo
	echo "READONLY_EPREFIX=\"${PARENT_EPREFIX}:DEPEND,RDEPEND,PDEPEND,HDEPEND\""
	echo "EPREFIX=\"${CHILD_EPREFIX}\""
	echo "BASE_EPREFIX=\"${PARENT_EPREFIX}\""
	echo "DISTDIR=\"${CHILD_EPREFIX}/usr/portage/distfiles\""
	echo "PORTAGE_USER='$USER'"
	echo "PORTAGE_GROUP='$(id -g -n $USER)'"
	echo "PORTAGE_ROOT_USER='$USER'"
	echo "PORTAGE_INST_UID=\"$(id -u $USER)\""
	echo "PORTAGE_INST_GID=\"$(id -g $USER)\""
	echo "PORTAGE_TMPDIR=\"/dev/shm/$USER/${CHILD_EPREFIX##*/}\""

	if test "${DO_SOURCES}" == "yes"; then
		# don't fail if nothing found
		for f in /etc/portage/make.conf /etc/make.conf; do
			if [[ -r ${PARENT_EPREFIX}${f} ]]; then
				egrep "^source .*" "${PARENT_EPREFIX}${f}" 2>/dev/null || true
				break;
			fi
		done
	fi
) > "${CHILD_EPREFIX}"/etc/portage/make.conf
eend_exit $?

ebegin "creating profile/use.mask"
cat > "${CHILD_EPREFIX}"/etc/portage/profile/use.mask/prefix-chain-setup <<-'EOM'
	# masked in base profile, unmask here
	-prefix-chain
	EOM
eend_exit $?

ebegin "creating profile/use.force"
cat > "${CHILD_EPREFIX}"/etc/portage/profile/use.force/prefix-chain-setup <<-'EOM'
	# masked in base profile, force here
	prefix-chain
	EOM
eend_exit $?

ebegin "creating environment"
(
	echo "CPATH=\"${CHILD_EPREFIX}/usr/include:$(. ${PARENT_EPREFIX}/etc/env.d/01libs && echo $CPATH)\""
	echo "LIBRARY_PATH=\"${CHILD_EPREFIX}/usr/lib64:${CHILD_EPREFIX}/lib64:$(. ${PARENT_EPREFIX}/etc/env.d/01libs && echo $LIBRARY_PATH)\""
) > "${CHILD_EPREFIX}"/etc/env.d/01libs
eend_exit $?

#
# create the make.profile symlinks.
#
ebegin "creating make.profile"
(
	ln -s "${CHILD_PROFILE}" "${CHILD_EPREFIX}/etc/portage/make.profile"
)
eend_exit $?

#
# copy portage config files
#
ebegin "copying portage config files"
(
	mkdir -p "${CHILD_EPREFIX}"/usr/share/portage/config/sets
	mkdir -p "${CHILD_EPREFIX}"/etc/init.d
	mkdir -p $(. ${CHILD_EPREFIX}/etc/portage/make.conf && echo $PORTAGE_TMPDIR)
	cp "${PARENT_EPREFIX}"/etc/init.d/functions.sh "${CHILD_EPREFIX}"/etc/init.d/functions.sh
	cp "${PARENT_EPREFIX}"/usr/share/portage/config/make.globals "${CHILD_EPREFIX}"/usr/share/portage/config/make.globals
	sed -i -e "s/PORTAGE_USER='.*'/PORTAGE_USER='$USER'/" \
	       -e "s/PORTAGE_GROUP='.*'/PORTAGE_GROUP='$(id -g -n $USER)'/" \
	       -e "s/PORTAGE_ROOT_USER='.*'/PORTAGE_ROOT_USER='$USER'/" \
	       -e "s/PORTAGE_INST_UID=\".*\"/PORTAGE_INST_UID=\"$(id -u $USER)\"/" \
	       -e "s/PORTAGE_INST_GID=\".*\"/PORTAGE_INST_GID=\"$(id -g $USER)\"/" \
	    ${CHILD_EPREFIX}/usr/share/portage/config/make.globals
	cp "${PARENT_EPREFIX}"/usr/share/portage/config/sets/portage.conf "${CHILD_EPREFIX}"/usr/share/portage/config/sets/portage.conf
	sed -i -e 's/@profile @selected @system/@profile @selected/' ${CHILD_EPREFIX}/usr/share/portage/config/sets/portage.conf
	cp -r ${PARENT_EPREFIX}/etc/portage/package.use ${CHILD_EPREFIX}/etc/portage/package.use
	cp -r "${PARENT_EPREFIX}"/etc/portage/repos.conf "${CHILD_EPREFIX}"/etc/portage/
)
eend $?

#
# adjust permissions of generated files.
#
ebegin "adjusting permissions"
(
	chmod 644 "${CHILD_EPREFIX}"/etc/portage/make.conf
)
eend_exit $?

#
# now merge some basics.
#
ebegin "installing required basic packages"
(
	# this -pv is there to avoid the global update output, which is
	# there on the first emerge run. (thus, just cosmetics).
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -p1qO baselayout-prefix > /dev/null 2>&1 || exit 1

	set -e
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO \
		gentoo-functions baselayout-prefix prefix-chain-utils gentoo-functions python-exec

	# merge with the parent's chost. this forces the use of the parent
	# compiler, which generally would be illegal - this is an exception.
	# This is required for example on winnt, because the wrapper has to
	# be able to use/resolve symlinks, etc. native winnt binaries miss that
	# ability, but interix binaries don't.
	#PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" CHOST="${PARENT_CHOST}" emerge -1qO gcc-config

	# select the chain wrapper profile from gcc-config
	#env -i "$(type -P bash)" "${CHILD_EPREFIX}"/usr/bin/gcc-config 1

	# do this _AFTER_ selecting the correct compiler!
	#PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO libtool

	# These will be found in the parent, so make sure emerged in order
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO eselect 
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO eselect-envmod
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO eselect-cray
	PORTAGE_CONFIGROOT="${CHILD_EPREFIX}" EPREFIX="${CHILD_EPREFIX}" emerge -1qO baselayout-prefix
)
eend_exit $?

domodule="@DOMODULE@"
if [ ! -z "$domodule" ]; then
	ebegin "Setting up module file"
	(
		echo -n "Enter the name for this module:"
		read PACKAGE
		echo -n "Enter the version of this module:"
		read VERSION
		echo -n "Enter the prefix for environment variables:"
		read ENVVAR_PREFIX
		cp "${PARENT_EPREFIX}"/usr/share/prefix-chaining/modulefile.in "${CHILD_EPREFIX}"/usr/share/modulefile
		sed -i -e "s:@CHILD_EPREFIX@:${CHILD_EPREFIX}:" -e "s/@ENVVAR_PREFIX@/${ENVVAR_PREFIX}/g" -e "s/@PACKAGE@/${PACKAGE}/" -e "s/@VERSION@/${VERSION}/" "${CHILD_EPREFIX}"/usr/share/modulefile
		einfo "A environment module file for this prefix has been installed into ${CHILD_EPREFIX}/usr/share/modulefile"
		if [ -z "${INSTALL_MODULEFILE_IN_PARENT}" ]; then
			mkdir -p "${PARENT_EPREFIX}"/usr/share/modulefiles/${PACKAGE}
			ln -s "${CHILD_EPREFIX}"/usr/share/modulefile "${PARENT_EPREFIX}"/usr/share/modulefiles/${PACKAGE}/${VERSION}
		fi
	)
	eend_exit $?
fi

#
# wow, all ok :)
#
ewarn
ewarn "all done. don't forget to tune ${CHILD_EPREFIX}/etc/portage/make.conf."
ewarn "to enter the new prefix, run \"${CHILD_EPREFIX}/startprefix\"."
ewarn
EOF
}
