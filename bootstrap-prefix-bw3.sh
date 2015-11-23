#!/usr/bin/env bash
# Copyright 2006-2015 Gentoo Foundation; Distributed under the GPL v2
# $Id: bootstrap-prefix.sh 61818 2014-01-08 07:28:16Z haubi $

trap 'exit 1' TERM KILL INT QUIT ABRT

# some basic output functions
eerror() { echo "!!! $*" 1>&2; }
einfo() { echo "* $*"; }

# prefer gtar over tar
[[ x$(type -t gtar) == "xfile" ]] \
	&& TAR="gtar" \
	|| TAR="tar"

## Functions Start Here

econf() {
	${CONFIG_SHELL} ./configure \
		--host=${CHOST} \
		--prefix="${ROOT}"/tmp/usr \
		--mandir="${ROOT}"/tmp/usr/share/man \
		--infodir="${ROOT}"/tmp/usr/share/info \
		--datadir="${ROOT}"/tmp/usr/share \
		--sysconfdir="${ROOT}"/tmp/etc \
		--localstatedir="${ROOT}"/tmp/var/lib \
		--build=${CHOST} \
		"$@" || return 1
}

efetch() {
	if [[ ! -e ${DISTDIR}/${1##*/} ]] ; then
	  	if [[ ${OFFLINE_MODE} ]]; then
		  echo "I needed ${1##*/} from $1 or ${GENTOO_MIRRORS}/distfiles/${1##*/} in $DISTDIR"
		  read
		  [[ -e ${DISTDIR}/${1##*/} ]] && return 0
		  #Give fetch a try 
		fi

		if [[ -z ${FETCH_COMMAND} ]] ; then
			# Try to find a download manager, we only deal with wget,
			# curl, FreeBSD's fetch and ftp.
			if [[ x$(type -t wget) == "xfile" ]] ; then
				FETCH_COMMAND="wget"
			elif [[ x$(type -t ftp) == "xfile" ]] ; then
				FETCH_COMMAND="ftp"
			elif [[ x$(type -t curl) == "xfile" ]] ; then
				einfo "WARNING: curl doesn't fail when downloading fails, please check its output carefully!"
				FETCH_COMMAND="curl -L -O"
			elif [[ x$(type -t fetch) == "xfile" ]] ; then
				FETCH_COMMAND="fetch"
			else
				eerror "no suitable download manager found (need wget, curl, fetch or ftp)"
				eerror "could not download ${1##*/}"
				exit 1
			fi
		fi

		mkdir -p "${DISTDIR}" >& /dev/null
		einfo "Fetching ${1##*/}"
		pushd "${DISTDIR}" > /dev/null
		# try for mirrors first, then try given location
		${FETCH_COMMAND} "${GENTOO_MIRRORS}/distfiles/${1##*/}" < /dev/null
		[[ ! -f ${1##*/} && ${1} != ${GENTOO_MIRRORS}/distfiles/${1##*/} ]] \
			&& ${FETCH_COMMAND} "$1" < /dev/null
		if [[ ! -f ${1##*/} ]] ; then
			eerror "downloading ${1} failed!"
			return 1
		fi
		popd > /dev/null
	fi
	return 0
}

# template
# bootstrap_() {
# 	PV=
# 	A=
# 	einfo "Bootstrapping ${A%-*}"

# 	efetch ${A} || return 1

# 	einfo "Unpacking ${A%-*}"
# 	export S="${PORTAGE_TMPDIR}/${PN}"
# 	rm -rf ${S}
# 	mkdir -p ${S}
# 	cd ${S}
# 	$TAR -zxf ${DISTDIR}/${A} || return 1
# 	S=${S}/${PN}-${PV}
# 	cd ${S}

# 	einfo "Compiling ${A%-*}"
# 	econf || return 1
# 	$MAKE ${MAKEOPTS} || return 1

# 	einfo "Installing ${A%-*}"
# 	$MAKE install || return 1

# 	einfo "${A%-*} successfully bootstrapped"
# }

configure_cflags() {
	export CPPFLAGS="-I${ROOT}/tmp/usr/include"
	export LDFLAGS="-L${ROOT}/tmp/usr/lib -Wl,-rpath=${ROOT}/tmp/usr/lib -Wl,--enable-new-dtags" 
}

configure_toolchain() {
	true
}

bootstrap_setup() {
        local profile="prefix/linux/amd64-bw"
        einfo "setting up some guessed defaults"

	mkdir -p ${ROOT}/etc/portage
	mkdir -p ${ROOT}/tmp/etc/portage

        if [[ ! -f ${ROOT}/etc/portage/make.conf ]] ; then
                {
                        echo 'MARCH="bdver1"'
                        echo 'CFLAGS="${CFLAGS} -O2 -pipe -march=$MARCH -I$EPREFIX/usr/include -I/usr/include -L$EPREFIX/lib -L$EPREFIX/usr/lib -L/lib64 -L/usr/lib64"'
                        echo 'CXXFLAGS="${CFLAGS}"'
                        echo 'FFLAGS="${CFLAGS}"'
                        echo 'USE="prefix-chaining unicode nls jpeg jpeg2k lcms tiff truetype lapack -e2fsprogs lzo lzma python mpi threads hdf hdf5 sqlite"'
                        echo 'MAKEOPTS="-j9"'
                        echo 'LDFLAGS="${LDFLAGS} -Wl,--rpath=$EPREFIX/lib -Wl,--rpath=$EPREFIX/usr/lib -Wl,--enable-new-dtags"'
                        echo "CONFIG_SHELL=\"${ROOT}/bin/bash\""
                        echo "BASE_EPREFIX=\"${ROOT}\""
			echo "PORTAGE_TMPDIR=\"/dev/shm/$USER/${ROOT##*/}/\""
			#echo "CC=cc"
			#echo "CXX=CC"
			#echo "FC=ftn"
			#echo "F77=ftn"
			#echo "F95=ftn"
			echo "CRAYPE_LINK_TYPE=dynamic"
			echo "CRAY_ADD_RPATH=yes"
			echo "PORTDIR=\"${PORTDIR}\""
                        if [[ -n ${PREFIX_DISABLE_USR_SPLIT} ]] ; then
                                echo
                                echo "# This disables /usr-split, removing this will break"
                                echo "PREFIX_DISABLE_GEN_USR_LDSCRIPT=yes"
                        fi
                        [[ -n $PORTDIR_OVERLAY ]] && \
                                echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} ${PORTDIR_OVERLAY}\""
                        [[ ${OFFLINE_MODE} ]] && \
                                echo 'FETCHCOMMAND="bash -c \"echo I need \${FILE} from \${URI} in \${DISTDIR}; read\""'
                } > "${ROOT}"/etc/portage/make.conf
        fi

        mkdir -p ${ROOT}/etc/portage/repos.conf

        if [[ ! -f ${ROOT}/etc/portage/repos.conf/bwgp.conf ]] ; then
                {
                        echo '[BWGentooPrefix]'
                        echo "location = ${ROOT%/}/usr/local/bw-python-gentoo-prefix-overlay"
                        echo 'masters = gentoo_prefix'
                        echo 'sync-type = git'
                        echo 'sync-uri = https://github.com/camaclean/bw-python-gentoo-prefix-overlay.git'
                        echo 'auto-sync = yes' 
                } > ${ROOT}/etc/portage/repos.conf/bwgp.conf
        fi

	if [[ ! -f ${ROOT}/etc/portage/repos.conf/science.conf ]] ; then
		{
			echo '[science]'
			echo "location = ${ROOT%/}/usr/local/science"
			echo 'masters = gentoo'
			echo 'sync-type = git'
			echo 'sync-uri = https://github.com/gentoo-science/sci.git'
			echo 'auto-sync = yes'
		}
	fi

        if [[ ! -f ${ROOT}/etc/portage/repos.conf/gentoo_prefix.conf ]] ; then
                {
                        echo '[DEFAULT]'
                        echo 'main-repo = gentoo_prefix'
                        echo 'eclass-overrides = BWGentooPrefix'
                        echo ''
                        echo '[gentoo_prefix]'
                        echo "location = ${ROOT}/usr/portage"
                        echo 'sync-type = rsync'
                        echo 'sync-uri = rsync://rsync.prefix.bitzolder.nl/gentoo-portage-prefix'
                } > ${ROOT}/etc/portage/repos.conf/gentoo_prefix.conf
        fi

	cp "${ROOT}"/etc/portage/make.conf "${ROOT}"/tmp/etc/portage/make.conf
	cp -r "${ROOT}"/etc/portage/repos.conf "${ROOT}"/tmp/etc/portage/

        if [[ ! -e "${ROOT}"/etc/portage/make.profile ]] ; then
                local fullprofile="${ROOT}/usr/local/bw-python-gentoo-prefix-overlay/profiles/prefix/linux/amd64-bw"
                ln -snf "${fullprofile}" "${ROOT}"/etc/portage/make.profile
                einfo "Your profile is set to ${fullprofile}."
        fi
        if [[ ! -e "${ROOT}"/tmp/etc/portage/make.profile ]] ; then
                local fullprofile="${ROOT}/usr/local/bw-python-gentoo-prefix-overlay/profiles/prefix/linux/amd64-bw"
                ln -snf "${fullprofile}" "${ROOT}"/tmp/etc/portage/make.profile
                einfo "Your profile is set to ${fullprofile}."
        fi
}

do_tree() {
	local x
	for x in etc{,/portage} usr/{{,s}bin,lib} var/tmp var/lib/portage var/log/portage var/db;
	do
		[[ -d ${ROOT}/${x} ]] || mkdir -p "${ROOT}/${x}"
	done
	if [[ ${PREFIX_DISABLE_USR_SPLIT} == "yes" ]] ; then
		# note to self: don't make bin a symlink to usr/bin for
		# coreutils installs symlinks to from usr/bin to bin, which in
		# case they are the same boils down to a pointless indirection
		# to self
		for x in lib sbin ; do
			[[ -e ${ROOT}/${x} ]] || ( cd "${ROOT}" && ln -s usr/${x} )
		done
	else
		for x in lib sbin ; do
			[[ -d ${ROOT}/${x} ]] || mkdir -p "${ROOT}/${x}"
		done
	fi
	mkdir -p "${PORTDIR}"
	if [[ ! -e ${PORTDIR}/.unpacked ]] && [[ ${PORTDIR} == ${ROOT}/usr/portage ]] ; then
		efetch "$1/$2" || return 1
		[[ -e ${PORTDIR} ]] || mkdir -p ${PORTDIR}
		einfo "Unpacking, this may take a while"
		bzip2 -dc ${DISTDIR}/$2 | $TAR -xf - -C ${PORTDIR} --strip-components=1 || return 1
		touch ${PORTDIR}/.unpacked
	fi
}

bootstrap_tree() {
	local PV="20150617"
	if [[ -n ${LATEST_TREE_YES} ]]; then
		do_tree "${SNAPSHOT_URL}" portage-latest.tar.bz2
	else
		do_tree http://dev.gentoo.org/~grobian/distfiles prefix-overlay-${PV}.tar.bz2
	fi
	mkdir -p "${ROOT}/usr/local"
	if [[ -d "${ROOT}/usr/local/bw-python-gentoo-prefix-overlay" ]] ; then
		cd "${ROOT}/usr/local/bw-python-gentoo-prefix-overlay"
		git pull
		cd -
	else
		cd "${ROOT}/usr/local"
		git clone https://github.com/camaclean/bw-python-gentoo-prefix-overlay.git
		cd -
	fi
}

bootstrap_startscript() {
	local theshell=${SHELL##*/}
	if [[ ${theshell} == "sh" ]] ; then
		einfo "sh is a generic shell, using bash instead"
		theshell="bash"
	fi
	if [[ ${theshell} == "csh" ]] ; then
		einfo "csh is a prehistoric shell not available in Gentoo, switching to tcsh instead"
		theshell="tcsh"
	fi
	einfo "Trying to emerge the shell you use, if necessary by running:"
	einfo "emerge -u ${theshell}"
	if ! emerge -u ${theshell} ; then
		eerror "Your shell is not available in portage, hence we cannot" > /dev/stderr
		eerror "automate starting your prefix, set SHELL and rerun this script" > /dev/stderr
		return 1
	fi
	einfo "Creating the Prefix start script (startprefix)"
	# currently I think right into the prefix is the best location, as
	# putting it in /bin or /usr/bin just hides it some more for the
	# user
	sed \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${ROOT}|g" \
		-e "s|@GENTOO_PORTAGE_BASE_EPREFIX@|${ROOT}|g" \
		"${ROOT}"/usr/local/bw-python-gentoo-prefix-overlay/sys-apps/prefix-chain-utils/files/startprefix.in \
		> "${ROOT}"/startprefix
	chmod 755 "${ROOT}"/startprefix
	einfo "To start Gentoo Prefix, run the script ${ROOT}/startprefix"
	einfo "You can copy this file to a more convenient place if you like."
}

bootstrap_portage() {
	# Set TESTING_PV in env if you want to test a new portage before bumping the
	# STABLE_PV that is known to work. Intended for power users only.
	## It is critical that STABLE_PV is the lastest (non-masked) version that is
	## included in the snapshot for bootstrap_tree.
	STABLE_PV="2.2.20"
	[[ ${TESTING_PV} == latest ]] && TESTING_PV="2.2.20"
	PV="${TESTING_PV:-${STABLE_PV}}"
	A=prefix-portage-${PV}.tar.bz2
	einfo "Bootstrapping ${A%-*}"
		
	efetch ${DISTFILES_URL}/${A} || return 1

	einfo "Unpacking ${A%-*}"
	export S="${PORTAGE_TMPDIR}"/portage-${PV}
	ptmp=${S}
	rm -rf "${S}" >& /dev/null
	mkdir -p "${S}" >& /dev/null
	cd "${S}"
	bzip2 -dc "${DISTDIR}/${A}" | $TAR -xf - || return 1
	S="${S}/prefix-portage-${PV}"
	cd "${S}"

	patch -p1 < "${ROOT}"/usr/portage/sys-apps/portage/files/portage-2.2.10.1-brokentty-more-platforms.patch # now upstream

	# disable ipc
	sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
		-i pym/_emerge/AbstractEbuildProcess.py || \
		return 1

	# Portage checks for valid shebangs. These may (xz-utils) originate
	# in CONFIG_SHELL (AIX), which originates in PORTAGE_BASH then.
	# So we need to ensure portage's bash is valid as shebang too.
	mkdir -p "${ROOT}"/tmp/bin "${ROOT}"/bin || return 1
	[[ -x ${ROOT}/tmp/bin/bash ]] || [[ ! -x ${ROOT}/tmp/usr/bin/bash ]] || ln -s ../usr/bin/bash "${ROOT}"/tmp/bin/bash || return 1
	[[ -x ${ROOT}/tmp/bin/bash ]] || ln -s "${BASH}" "${ROOT}"/tmp/bin/bash || return 1
	[[ -x ${ROOT}/tmp/bin/sh ]] || ln -s bash "${ROOT}"/tmp/bin/sh || return 1
	[[ -x ${ROOT}/bin/sh ]] || ln -s ../tmp/bin/sh "${ROOT}"/bin/sh || return 1
	export PORTAGE_BASH="${ROOT}"/tmp/bin/bash

	einfo "Compiling ${A%-*}"
	econf \
		--with-offset-prefix="${ROOT}"/tmp \
		--with-portage-user="`id -un`" \
		--with-portage-group="`id -gn`" \
		--with-extra-path="${PATH}" \
		|| return 1
	$MAKE ${MAKEOPTS} || return 1

 	einfo "Installing ${A%-*}"
	$MAKE install || return 1

	cd "${ROOT}"
	rm -Rf ${ptmp} >& /dev/null

	# Some people will skip the tree() step and hence var/log is not created 
	# As such, portage complains..
	mkdir -p "${ROOT}"/var/log "${ROOT}"/tmp/var/log

	# in Prefix the sed wrapper is deadly, so kill it
	rm -f "${ROOT}"/tmp/usr/lib/portage/bin/ebuild-helpers/sed

	[[ -e "${ROOT}"/tmp/usr/portage ]] || ln -s "${PORTDIR}" "${ROOT}"/tmp/usr/portage

	if [[ -s ${PORTDIR}/profiles/repo_name ]]; then
		# sync portage's repos.conf with the tree being used
		sed -i -e "s,gentoo_prefix,$(<"${PORTDIR}"/profiles/repo_name)," "${ROOT}"/tmp/usr/share/portage/config/repos.conf || return 1
	fi

	einfo "${A%-*} successfully bootstrapped"
}

bootstrap_gnu() {
	local PN PV A S
	PN=$1
	PV=$2

	einfo "Bootstrapping ${PN}"

	for t in tar.gz tar.xz tar.bz2 tar ; do
		A=${PN}-${PV}.${t}

		# save the user some useless downloading
		if [[ ${t} == tar.gz ]] ; then
			type -P gzip > /dev/null || continue
		fi
		if [[ ${t} == tar.xz ]] ; then
			type -P xz > /dev/null || continue
		fi
		if [[ ${t} == tar.bz2 ]] ; then
			type -P bzip2 > /dev/null || continue
		fi

		URL=${GNU_URL}/${PN}/${A}
		efetch ${URL} || continue

		einfo "Unpacking ${A%-*}"
		S="${PORTAGE_TMPDIR}/${PN}-${PV}"
		rm -rf "${S}"
		mkdir -p "${S}"
		cd "${S}"
		if [[ ${t} == "tar.gz" ]] ; then
			gzip -dc "${DISTDIR}"/${URL##*/} | $TAR -xf - || continue
		elif [[ ${t} == "tar.xz" ]] ; then
			xz -dc "${DISTDIR}"/${URL##*/} | $TAR -xf - || continue
		elif [[ ${t} == "tar.bz2" ]] ; then
			bzip2 -dc "${DISTDIR}"/${URL##*/} | $TAR -xf - || continue
		elif [[ ${t} == "tar" ]] ; then
			$TAR -xf "${DISTDIR}"/${A} || continue
		else
			einfo "unhandled extension: $t"
			return 1
		fi
		break
	done
	S="${S}"/${PN}-${PV}
	[[ -d ${S} ]] || return 1
	cd "${S}" || return 1

	local myconf=""
	if [[ ${PN} == "grep" ]] ; then
		# Solaris and OSX don't like it when --disable-nls is set,
		# so just don't set it at all.
		# Solaris 11 has a messed up prce installation.  We don't need
		# it anyway, so just disable it
		myconf="${myconf} --disable-perl-regexp"
		# Except interix really needs it for grep.
		[[ $CHOST == *interix* ]] && myconf="${myconf} --disable-nls"
	fi

	# Darwin9 in particular doesn't compile when using system readline,
	# but we don't need any groovy input at all, so just disable it
	[[ ${PN} == "bash" ]] && myconf="${myconf} --disable-readline"

	# Don't do ACL stuff on Darwin, especially Darwin9 will make
	# coreutils completely useless (install failing on everything)
	# Don't try using gmp either, it may be that just the library is
	# there, and if so, the buildsystem assumes the header exists too
	[[ ${PN} == "coreutils" ]] && \
		myconf="${myconf} --disable-acl --without-gmp"

	if [[ ${PN} == "tar" && ${CHOST} == *-hpux* ]] ; then
		# Fix a compilation error due to a missing definition
		export CPPFLAGS="${CPPFLAGS} -DCHAR_BIT=8"
	fi

	# Gentoo Bug 400831, fails on Ubuntu with libssl-dev installed
	[[ ${PN} == "wget" ]] && myconf="${myconf} --without-ssl"

	# we do not have pkg-config to find lib/libffi-*/include/ffi.h
	[[ ${PN} == "libffi" ]] && 
	sed -i -e '/includesdir =/s/=.*/= $(includedir)/' include/Makefile.in

	# we have to build the libraries for correct bitwidth
	[[ " libffi " == *" ${PN} "* ]] &&
	case $CHOST in
	(x86_64-*-*|sparcv9-*-*)
		export CFLAGS="-m64"
		;;
	(i?86-*-*)
		export CFLAGS="-m32"
		;;
	esac

	einfo "Compiling ${PN}"
	econf ${myconf} || return 1
	if [[ ${PN} == "make" && $(type -t $MAKE) != "file" ]]; then
		./build.sh || return 1
	else
		$MAKE ${MAKEOPTS} || return 1
	fi

	einfo "Installing ${PN}"
	if [[ ${PN} == "make" && $(type -t $MAKE) != "file" ]]; then
		./make install MAKE="${S}/make" || return 1
	else
		$MAKE install || return 1
	fi

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${PN}-${PV} successfully bootstrapped"
}

bootstrap_python() {
	PV=2.7.3

	case $CHOST in
		*-*-aix*)
			# TODO: freebsd 10 also seems to need this
			A=Python-${PV}.tar.bz2 # patched one breaks
			patch=true
		;;
		*)
			A=python-${PV}-patched.tar.bz2
			patch=false
		;;
	esac

	einfo "Bootstrapping ${A%-*}"

	# don't really want to put this on the mirror, since they are
	# non-vanilla sources, bit specific for us
	efetch ${DISTFILES_URL}/${A} || return 1

	einfo "Unpacking ${A%%-*}"
	export S="${PORTAGE_TMPDIR}/python-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	bzip2 -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	S="${S}"/Python-${PV}
	cd "${S}"
	rm -rf Modules/_ctypes/libffi* || return 1
	rm -rf Modules/zlib || return 1

	if ${patch}; then
		# This patch is critical and needs to be applied even
		# when using the otherwise unpatched sources.
		efetch "http://dev.gentoo.org/~redlizard/distfiles/02_all_disable_modules_and_ssl.patch"
		patch -p0 < "${DISTDIR}"/02_all_disable_modules_and_ssl.patch
	fi

	local myconf=""

	case $CHOST in
	(x86_64-*-*|sparcv9-*-*)
		export CFLAGS="-m64"
		;;
	(i?86-*-*)
		export CFLAGS="-m32"
		;;
	esac

	case $CHOST in
		*-linux*)
			# Bug 382263: make sure Python will know about the libdir in use for
			# the current arch
			libdir="-L/usr/lib/$($CC ${CFLAGS} -print-multi-os-directory)"
		;;
	esac

	# python refuses to find the zlib headers that are built in the offset,
	# same for libffi, which installs into compiler's multilib-osdir
	export CPPFLAGS="-I${ROOT}/tmp/usr/include"
	export LDFLAGS="${CFLAGS} -L${ROOT}/tmp/usr/lib -L${ROOT}/tmp/usr/lib64"
	# set correct flags for runtime for ELF platforms
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${ROOT}/tmp/usr/lib ${libdir}"

	# if the user has a $HOME/.pydistutils.cfg file, the python
	# installation is going to be screwed up, as reported by users, so
	# just make sure Python won't find it
	export HOME="${S}"

	export PYTHON_DISABLE_MODULES="_bsddb bsddb bsddb185 bz2 crypt _ctypes_test _curses _curses_panel dbm _elementtree gdbm _locale nis pyexpat readline _sqlite3 _tkinter"
	export PYTHON_DISABLE_SSL=1
	export OPT="${CFLAGS}"

	einfo "Compiling ${A%-*}"

	#some ancient versions of hg fail with "hg id -i", so help configure to not find them
	# do not find libffi via pkg-config
	HAS_HG=no \
	PKG_CONFIG= \
	econf \
		--with-system-ffi \
		--disable-toolbox-glue \
		--disable-ipv6 \
		--disable-shared \
		${myconf} || return 1
	$MAKE ${MAKEOPTS} || return 1

	einfo "Installing ${A%-*}"
	$MAKE -k install || echo "??? Python failed to install *sigh* continuing anyway"
	cd "${ROOT}"/tmp/usr/bin
	ln -sf python${PV%.*} python
	cd "${ROOT}"/tmp/usr/lib
	# messes up python emerges, and shouldn't be necessary for anything
	# http://forums.gentoo.org/viewtopic-p-6890526.html
	rm -f libpython${PV%.*}.a

	einfo "${A%-*} bootstrapped"
}

bootstrap_zlib_core() {
	# use 1.2.5 by default, current bootstrap guides
	PV="${1:-1.2.5}"
	A=zlib-${PV}.tar.gz

	einfo "Bootstrapping ${A%-*}"

	if ! efetch ${GENTOO_MIRRORS}/distfiles/${A} ; then
		A=zlib-${PV}.tar.bz2
		efetch ${GENTOO_MIRRORS}/distfiles/${A} || return 1
	fi

	einfo "Unpacking ${A%%-*}"
	export S="${PORTAGE_TMPDIR}/zlib-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	if [[ ${A} == *.tar.gz ]] ; then
		gzip -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	else
		bzip2 -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	fi
	S="${S}"/zlib-${PV}
	cd "${S}"

	if [[ ${CHOST} == x86_64-*-* || ${CHOST} == sparcv9-*-* ]] ; then
		# 64-bits targets need zlib as library (not just to unpack),
		# hence we need to make sure that we really bootstrap this
		# 64-bits (in contrast to the tools which we don't care if they
		# are 32-bits)
		export CC="${CC} -m64"
	elif [[ ${CHOST} == i?86-*-* ]] ; then
		# This is important for bootstraps which are 64-native, but we
		# want 32-bits, such as most Linuxes, and more recent OSX.
		# OS X Lion and up default to a 64-bits userland, so force the
		# compiler to 32-bits code generation if requested here
		export CC="${CC} -m32"
	fi
	# 1.2.5 suffers from a concurrency problem
	[[ ${PV} == 1.2.5 ]] && MAKEOPTS=

	einfo "Compiling ${A%-*}"
	CHOST= ${CONFIG_SHELL} ./configure --prefix="${ROOT}"/tmp/usr || return 1
	$MAKE ${MAKEOPTS} || return 1

	einfo "Installing ${A%-*}"
	$MAKE install || return 1

	# this lib causes issues when emerging python again on Solaris
	# because the tmp lib path is in the library search path there
	rm -Rf "${ROOT}"/tmp/usr/lib/libz*.a

	if [[ ${CHOST} == *-aix* ]]; then
		# No aix-soname support, but symlinks when built with gcc. This breaks
		# later on when aix-soname is added within Prefix, where the lib.so.1
		# is an archive then, while finding this one first due to possible
		# rpath ordering issues.
		rm -f "${ROOT}"/tmp/usr/lib/libz.so.1
	fi

	einfo "${A%-*} bootstrapped"
}

bootstrap_zlib() {
	bootstrap_zlib_core 1.2.8 || bootstrap_zlib_core 1.2.7 || \
	bootstrap_zlib_core 1.2.6 || bootstrap_zlib_core 1.2.5
}

bootstrap_libffi() {
	bootstrap_gnu libffi 3.2.1
}

bootstrap_sed() {
	bootstrap_gnu sed 4.2.2 || bootstrap_gnu sed 4.2.1
}

bootstrap_findutils() {
	bootstrap_gnu findutils 4.5.10 || bootstrap_gnu findutils 4.2.33
}

bootstrap_wget() {
	bootstrap_gnu wget 1.13.4
}

bootstrap_grep() {
	# don't use 2.13, it contains a bug that bites, bug #425668
	# 2.9 is the last version provided as tar.gz (platforms without xz)
	# 2.7 is necessary for Solaris/OpenIndiana (2.8, 2.9 fail to configure)
	bootstrap_gnu grep 2.14 || bootstrap_gnu grep 2.12 || \
		bootstrap_gnu grep 2.9 || bootstrap_gnu grep 2.7
}

bootstrap_coreutils() {
	# 8.12 for FreeBSD 9.1, bug #415439
	# 8.16 is the last version released as tar.gz
	bootstrap_gnu coreutils 8.17 || bootstrap_gnu coreutils 8.16 || \
	bootstrap_gnu coreutils 8.12 
}

bootstrap_tar() {
	bootstrap_gnu tar 1.26
}

bootstrap_make() {
	MAKEOPTS= # no GNU make yet
	bootstrap_gnu make 3.82
}

bootstrap_patch() {
	# 2.5.9 needed for OSX 10.6.x still?
	bootstrap_gnu patch 2.7.5 ||
	bootstrap_gnu patch 2.7.4 ||
	bootstrap_gnu patch 2.7.3 ||
	bootstrap_gnu patch 2.6.1
}

bootstrap_gawk() {
	bootstrap_gnu gawk 4.0.1 || bootstrap_gnu gawk 4.0.0 || \
		bootstrap_gnu gawk 3.1.8
}

bootstrap_binutils() {
	bootstrap_gnu binutils 2.17
}

bootstrap_texinfo() {
	bootstrap_gnu texinfo 4.8
}

bootstrap_bash() {
	bootstrap_gnu bash 4.2
}

bootstrap_bison() {
	bootstrap_gnu bison 2.6.2 || bootstrap_gnu bison 2.6.1 || \
		bootstrap_gnu bison 2.6 || bootstrap_gnu bison 2.5.1 || \
		bootstrap_gnu bison 2.4
}

bootstrap_m4() {
	bootstrap_gnu m4 1.4.17 || bootstrap_gnu m4 1.4.16 || bootstrap_gnu m4 1.4.15
}

bootstrap_gzip() {
	bootstrap_gnu gzip 1.4
}

bootstrap_bzip2() {
	local PN PV A S
	PN=bzip2
	PV=1.0.6
	A=${PN}-${PV}.tar.gz
	einfo "Bootstrapping ${A%-*}"

	efetch ${GENTOO_MIRRORS}/distfiles/${A} || return 1

	einfo "Unpacking ${A%-*}"
	S="${PORTAGE_TMPDIR}/${PN}-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	gzip -dc "${DISTDIR}"/${A} | $TAR -xf - || return 1
	S="${S}"/${PN}-${PV}
	cd "${S}"

	einfo "Compiling ${A%-*}"
	$MAKE || return 1

	einfo "Installing ${A%-*}"
	$MAKE PREFIX="${ROOT}"/tmp/usr install || return 1

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${A%-*} successfully bootstrapped"
}

bootstrap_stage1() { (
	# NOTE: stage1 compiles all tools (no libraries) in the native
	# bits-size of the compiler, which needs not to match what we're
	# bootstrapping for.  This is no problem since they're just tools,
	# for which it really doesn't matter how they run, as long AS they
	# run.  For libraries, this is different, since they are relied on
	# by packages we emerge lateron.
	# Changing this to compile the tools for the bits the bootstrap is
	# for, is a BAD idea, since we're extremely fragile here, so
	# whatever the native toolchain is here, is what in general works
	# best.

	export CC CXX

	# run all bootstrap_* commands in a subshell since the targets
	# frequently pollute the environment using exports which affect
	# packages following (e.g. zlib builds 64-bits)

	echo "$PATH"
	echo "`which patch`"

	# don't rely on $MAKE, if make == gmake packages that call 'make' fail
	[[ $(make --version 2>&1) == *GNU* ]] || (bootstrap_make) || return 1
	[[ ${OFFLINE_MODE} ]] || type -P wget > /dev/null || (bootstrap_wget) || return 1
	[[ $(sed --version 2>&1) == *GNU* ]] || (bootstrap_sed) || return 1
	[[ $(m4 --version 2>&1) == *GNU*1.4.1?* ]] || (bootstrap_m4) || return 1
	[[ $(bison --version 2>&1) == *"(GNU Bison) 2."[345678]* ]] \
		|| [[ -x ${ROOT}/tmp/usr/bin/bison ]] \
		|| (bootstrap_bison) || return 1
	[[ $(uniq --version 2>&1) == *"(GNU coreutils) "[6789]* ]] \
		|| (bootstrap_coreutils) || return 1
	[[ $(find --version 2>&1) == *GNU* ]] || (bootstrap_findutils) || return 1
	[[ $(tar --version 2>&1) == *GNU* ]] || (bootstrap_tar) || return 1
	[[ $(patch --version 2>&1) == *"patch 2."[6-9]*GNU* ]] || (bootstrap_patch) || return 1
	[[ $(grep --version 2>&1) == *GNU* ]] || (bootstrap_grep) || return 1
	[[ $(awk --version < /dev/null 2>&1) == *GNU* ]] || bootstrap_gawk || return 1
	[[ $(bash --version 2>&1) == "GNU bash, version 4."[123456789]* && ${CHOST} != *-aix* ]] \
		|| [[ -x ${ROOT}/tmp/usr/bin/bash ]] \
		|| (bootstrap_bash) || return 1
	type -P bzip2 > /dev/null || (bootstrap_bzip2) || return 1
	# important to have our own (non-flawed one) since Python (from
	# Portage) and binutils use it
	for zlib in ${ROOT}/tmp/usr/lib/libz.* ; do
		[[ -e ${zlib} ]] && break
		zlib=
	done
	[[ -n ${zlib} ]] || (bootstrap_zlib) || return 1
	for libffi in ${ROOT}/tmp/usr/lib*/libffi.* ; do
		[[ -e ${libffi} ]] && break
		libffi=
	done
	[[ -n ${libffi} ]] || (bootstrap_libffi) || return 1
	# too vital to rely on a host-provided one
	[[ -x ${ROOT}/tmp/usr/bin/python ]] || (bootstrap_python) || return 1


	# checks itself if things need to be done still
	(bootstrap_tree) || return 1

	# setup a profile
	[[ -e ${ROOT}/etc/portage/make.profile && -e ${ROOT}/etc/portage/make.conf ]] || (bootstrap_setup) || return 1
	mkdir -p "${ROOT}"/tmp/etc/portage || return 1
	[[ -e ${ROOT}/tmp/etc/portage/make.profile ]] || cp -dpR "${ROOT}"/etc/portage "${ROOT}"/tmp/etc || return 1

	# setup portage
	[[ -e ${ROOT}/tmp/usr/bin/emerge ]] || (bootstrap_portage) || return 1

	einfo "stage1 successfully finished"
); }

bootstrap_stage1_log() {
	bootstrap_stage1 ${@} 2>&1 | tee -a ${ROOT}/stage1.log
	return ${PIPESTATUS[0]}
}

do_emerge_pkgs() {
	local opts=$1 ; shift
	local pkg vdb pvdb evdb
	for pkg in "$@"; do
		vdb=${pkg}
		if [[ ${vdb} == "="* ]] ; then
			vdb=${vdb#=}
		elif [[ ${vdb} == "<"* ]] ; then
			vdb=${vdb#<}
			vdb=${vdb%-r*}
			vdb=${vdb%-*}
			vdb=${vdb}-\*
		else
			vdb=${vdb}-\*
		fi
		for pvdb in ${EPREFIX}/var/db/pkg/${vdb%-*}-* ; do
			if [[ -d ${pvdb} ]] ; then
				evdb=${pvdb##*/}
				if [[ ${pkg} == "="* ]] ; then
					# exact match required (* should work here)
					[[ ${evdb} == ${vdb##*/} ]] && break
				else
					vdb=${vdb%-*}
					evdb=${evdb%-r*}
					evdb=${evdb%_p*}
					evdb=${evdb%-*}
					[[ ${evdb} == ${vdb#*/} ]] && break
				fi
			fi
			pvdb=
		done
		[[ -n ${pvdb} ]] && continue

		# Disable the STALE warning because the snapshot frequently gets stale.
		#
		# Need need to spam the user about news until the emerge -e system
		# because the tools aren't available to read the news item yet anyway.
		#
		# Avoid circular deps caused by the default profiles (and IUSE defaults).
		PORTAGE_CONFIGROOT="${EPREFIX}" \
		PORTAGE_SYNC_STALE=0 \
		FEATURES="-news ${FEATURES}" \
		PYTHONPATH="${ROOT}"/tmp/usr/lib/portage/pym \
		USE="-berkdb -fortran -gdbm -git -libcxx -nls -pcre -ssl -python bootstrap clang internal-glib ${USE}" \
		emerge -v --oneshot --root-deps ${opts} "${pkg}" || return 1
	done
}

bootstrap_stage2() {
	if ! type -P emerge > /dev/null ; then
		eerror "emerge not found, did you bootstrap stage1?"
		return 1
	fi
}

bootstrap_stage2_log() {
	bootstrap_stage2 ${@} 2>&1 | tee -a ${ROOT}/stage2.log
	return ${PIPESTATUS[0]}
}

bootstrap_stage3() {
	if ! type -P emerge > /dev/null ; then
		eerror "emerge not found, did you bootstrap stage1?"
		return 1
	fi
	
	#if ! type -P gcc > /dev/null ; then
	#	eerror "gcc not found, did you bootstrap stage2?"
	#	return 1
	#fi

	configure_toolchain || return 1
	export CONFIG_SHELL="${ROOT}"/tmp/bin/bash
	unset CC CXX

	emerge_pkgs() {
		EPREFIX="${ROOT}" \
		do_emerge_pkgs "$@"
	}

	# GCC sometimes decides that it needs to run makeinfo to update some
	# info pages from .texi files.  Obviously we don't care at this
	# stage and rather have it continue instead of abort the build
	export MAKEINFO="echo makeinfo GNU texinfo 4.13"
	
	# Build a native compiler.
	pkgs=(
		$([[ ${CHOST} == *-aix* ]] && echo dev-libs/libiconv ) # bash dependency
		sys-libs/ncurses
		sys-libs/readline
		app-shells/bash
		sys-apps/sed
		app-arch/xz-utils
		sys-apps/gentoo-functions
		sys-apps/baselayout-prefix
		sys-devel/m4
		sys-devel/flex
		sys-devel/binutils-config
		sys-libs/zlib
		${linker}
	)
	emerge_pkgs --nodeps "${pkgs[@]}" || return 1

	# work around eselect-python not being there, and llvm insisting on
	# using python
	ac_cv_path_PYTHON="${ROOT}/tmp/usr/bin/python" \
	emerge_pkgs --nodeps ${compiler} || return 1

	# Use $ROOT tools where possible from now on.
	rm -f "${ROOT}"/bin/sh
	ln -s bash "${ROOT}"/bin/sh
	export CONFIG_SHELL="${ROOT}/bin/bash"
	export PREROOTPATH="${ROOT}/usr/bin:${ROOT}/bin"
	unset MAKEINFO

	# Build portage and dependencies.
	pkgs=(
		sys-apps/coreutils
		sys-apps/findutils
		app-arch/tar
		sys-apps/grep
		sys-apps/gawk
		sys-devel/make
		sys-apps/file
		app-admin/eselect
		$( [[ ${OFFLINE_MODE} ]] || echo sys-devel/gettext )
		$( [[ ${OFFLINE_MODE} ]] || echo net-misc/wget )
		virtual/os-headers
		sys-apps/portage
	)
	emerge_pkgs "" "${pkgs[@]}" || return 1

	# Switch to the proper portage.
	hash -r

	# Get rid of the temporary tools.
	if [[ -d ${ROOT}/tmp/var/tmp ]] ; then
		rm -rf "${ROOT}"/tmp
		mkdir "${ROOT}"/tmp
	fi

	# Update the portage tree.
	treedate=$(date -f "${ROOT}"/usr/portage/metadata/timestamp +%s)
	nowdate=$(date +%s)
	[[ ( ! -e ${PORTDIR}/.unpacked ) && $((nowdate - (60 * 60 * 24))) -lt ${treedate} ]] || \
	if [[ ${OFFLINE_MODE} ]]; then
		# --keep used ${DISTDIR}, which make it easier to download a snapshot beforehand
		emerge-webrsync --keep || return 1
	else
		emerge --sync || emerge-webrsync || return 1
	fi

	# Portage should figure out itself what it needs to do, if anything
	USE="-git" emerge -u system || return 1
	emerge eselect-cray

	# remove anything that we don't need (compilers most likely)
	emerge --depclean

	eselect python set 1
	emerge -uvDN gentoolkit eix pillow native-mpi mpi4py libsci numpy matplotlib pycuda h5py netcdf4-python pandas statsmodels expose-python
	USE="-smp" emerge -v ipython
	emerge -v ipython ipython-expose
	emerge -v sympy sqlalchemy-migrate astropy dev-python/atom boost-numpy pysqlite pymysql pycairo wheel ropeide pylint kiwisolver yt jupyter_console natsort dev-python/mock mpmath nose pytest-cache pep8 pyyaml dev-db/redis redis-py chaco xlwt workerpool dev-python/sh bitarray nano numpydoc scikits_image ansi2html basemap argcomplete boto boto3 cvxopt pyephem mdp pyamg pyflakes pysam queuelib seaborn shapely peachpy
	einfo "stage3 successfully finished"
}

bootstrap_stage3_log() {
	bootstrap_stage3 ${@} 2>&1 | tee -a ${ROOT}/stage3.log
	return ${PIPESTATUS[0]}
}

bootstrap_interactive() {
	# No longer support gen_usr_ldscript stuff and the /usr split it
	# works around for in new bootstraps, this must be in line with what
	# eventually ends up in make.conf, see the end of stage3.  We don't
	# do this in bootstrap_setup() because in that case we'd also have
	# to cater for getting this right with manual bootstraps.
	export PREFIX_DISABLE_USR_SPLIT=yes 

	# immediately die on platforms that we know are impossible due to
	# brain-deadness (Debian/Ubuntu) or extremely hard dependency chains
	# (TODO NetBSD/OpenBSD)
	case ${CHOST} in
		*-linux-gnu)
			local toolchain_impossible=
			# Figure out if this is Ubuntu...
			if [[ $(lsb_release -is 2>/dev/null) == "Ubuntu" ]] ; then
				case "$(lsb_release -sr)" in
					[456789].*|10.*)
						: # good versions
						;;
					*)
						# Debian/Ubuntu have seriously fscked up their
						# toolchain to support their multi-arch crap
						# since Natty (11.04) that noone really wants,
						# and certainly not upstream.  Some details:
						# https://bugs.launchpad.net/ubuntu/+source/binutils/+bug/738098
						toolchain_impossible="Ubuntu >= 11.04 (Natty)"
						;;
				esac
			fi
			# Figure out if this is Debian
			if [[ -e /etc/debian_release ]] ; then
				case "$(< /etc/debian_release)" in
					hamm/*|slink/*|potato/*|woody/*|sarge/*|etch/*|lenny/*|squeeze/*)
						: # good versions
						;;
					*)
						# Debian introduced their big crap since Wheezy
						# (7.0), like for Ubuntu, see above
						toolchain_impossible="Debian >= 7.0 (Wheezy)"
						;;
				esac
			fi
			if [[ -n ${toolchain_impossible} ]] ; then
				# In short, it's impossible for us to compile a
				# compiler, since 1) gcc picks up our ld, which doesn't
				# support sysroot (can work around with a wrapper
				# script), 2) headers and libs aren't found (symlink
				# them to Prefix), 3) stuff like crtX.i isn't found
				# during bootstrap, since the bootstrap compiler doesn't
				# get any of our flags and doesn't know where to find
				# them (even if we copied them).  So we cannot do this,
				# unless we use the Ubuntu patches in our ebuilds, which
				# is a NO-GO area.
				cat << EOF
Oh My!  ${toolchain_impossible}!  AAAAAAAAAAAAAAAAAAAAARGH!  HELL comes over me!

EOF
				echo -n "..."
				sleep 1
				echo -n "."
				sleep 1
				echo -n "."
				sleep 1
				echo -n "."
				sleep 1
				echo
				echo
				cat << EOF
and over you.  You're on the worst Linux distribution from a developer's
(and so Gentoo Prefix) perspective since http://wiki.debian.org/Multiarch/.
Due to this multi-arch idea, it is IMPOSSIBLE for Gentoo Prefix to
bootstrap a compiler without using Debuntu patches, which is an absolute
NO-GO area!  GCC and binutils upstreams didn't just reject those patches
for fun.

I really can't help you, and won't waste any of your time either.  The
story simply ends here.  Sorry.
EOF
				exit 1
			fi
			;;
	esac

	cat <<"EOF"


                                             .
       .vir.                                d$b
    .d$$$$$$b.    .cd$$b.     .d$$b.   d$$$$$$$$$$$b  .d$$b.      .d$$b.
    $$$$( )$$$b d$$$()$$$.   d$$$$$$$b Q$$$$$$$P$$$P.$$$$$$$b.  .$$$$$$$b.
    Q$$$$$$$$$$B$$$$$$$$P"  d$$$PQ$$$$b.   $$$$.   .$$$P' `$$$ .$$$P' `$$$
      "$$$$$$$P Q$$$$$$$b  d$$$P   Q$$$$b  $$$$b   $$$$b..d$$$ $$$$b..d$$$
     d$$$$$$P"   "$$$$$$$$ Q$$$     Q$$$$  $$$$$   `Q$$$$$$$P  `Q$$$$$$$P
    $$$$$$$P       `"""""   ""        ""   Q$$$P     "Q$$$P"     "Q$$$P"
    `Q$$P"                                  """

             Welcome to the Gentoo Prefix interactive installer!


    I will attempt to install Gentoo Prefix on your system.  To do so, I'll
    ask  you some questions first.    After that,  you'll have to  practise
    patience as your computer and I try to figure out a way to get a lot of
    software  packages  compiled.    If everything  goes according to plan,
    you'll end up with what we call  "a Prefix install",  but by that time,
    I'll tell you more.


EOF
	[[ ${TODO} == 'noninteractive' ]] && ans=yes ||
	read -p "Do you want me to start off now? [Yn] " ans
	case "${ans}" in
		[Yy][Ee][Ss]|[Yy]|"")
			: ;;
		*)
			echo "Right.  Aborting..."
			exit 1
			;;
	esac

	if [[ ${UID} == 0 ]] ; then
		cat << EOF

Hmmm, you appear to be root, or at least someone with UID 0.  I really
don't like that.  The Gentoo Prefix people really discourage anyone
running Gentoo Prefix as root.  As a matter of fact, I'm just refusing
to help you any further here.
If you insist, you'll have go without my help, or bribe me.
EOF
		exit 1
	fi
	echo
	echo "It seems to me you are '${USER:-$(whoami 2> /dev/null)}' (${UID}), that looks cool to me."

	echo
	echo "I'm excited!  Seems we can finally do something productive now."

	cat << EOF

Ok, I'm going to do a little bit of guesswork here.  Thing is, your
machine appears to be identified by CHOST=${CHOST}.
EOF

	# eventually the user does know where to find a compiler
	[[ ${TODO} == 'noninteractive' ]] &&
	usergcc=$(type -P cc 2>/dev/null)

	# TODO: should we better use cc here? or check both?
	if ! type -P cc > /dev/null ; then
		echo
		echo "Woops! No compiler found!"
	else
		echo
		echo "Great!  You appear to have a compiler in your PATH"
	fi

	echo
	local ncpu=
    	ncpu=$(cat /proc/cpuinfo | grep processor | wc -l)
	# get rid of excess spaces (at least Solaris wc does)
	ncpu=$((ncpu + 0))
	# Suggest usage of 100% to 60% of the available CPUs in the range
	# from 1 to 14.  We limit to no more than 8, since we easily flood
	# the bus on those heavy-core systems and only slow down in that
	# case anyway.
	local tcpu=$((ncpu / 2 + 1))
	[[ ${tcpu} -gt 8 ]] && tcpu=8
	[[ -n ${USE_CPU_CORES} ]] && tcpu=${USE_CPU_CORES}
	cat << EOF

I did my utmost best, and found that you have ${ncpu} cpu cores.  If
this looks wrong to you, you can happily ignore me.  Based on the number
of cores you have, I came up with the idea of parallelising compilation
work where possible with ${tcpu} parallel make threads.  If you have no
clue what this means, you should go with my excellent default I've
chosen below, really!
EOF
	[[ ${TODO} == 'noninteractive' ]] && ans="" ||
	read -p "How many parallel make jobs do you want? [${tcpu}] " ans
	case "${ans}" in
		"")
			MAKEOPTS="-j${tcpu}"
			;;
		*)
			if [[ ${ans} -le 0 ]] ; then
				echo
				echo "You should have entered a non-zero integer number, obviously..."
				exit 1
			elif [[ ${ans} -gt ${tcpu} && ${tcpu} -ne 1 ]] ; then
				if [[ ${ans} -gt ${ncpu} ]] ; then
					cat << EOF

Want to push it very hard?  I already feel sorry for your poor box with
its mere ${ncpu} cpu cores.
EOF
				elif [[ $((ans - tcpu)) -gt 1 ]] ; then
					cat << EOF

So you think you can stress your system a bit more than my extremely
well thought out formula suggested you?  Hmmpf, I'll take it you know
what you're doing then.
EOF
					sleep 1
					echo "(are you?)"
				fi
			fi
			MAKEOPTS="-j${ans}"
			;;
	esac
	export MAKEOPTS

	#32/64 bits, multilib
	local candomultilib=no
	local t64 t32
	case "${CHOST}" in
		*86*-darwin9|*86*-darwin1[01234])
			# PPC/Darwin only works in 32-bits mode, so this is Intel
			# only, and only starting from Leopard (10.5, darwin9)
			candomultilib=yes
			t64=x86_64-${CHOST#*-}
			t32=i686-${CHOST#*-}
			;;
		*-solaris*)
			# Solaris is a true multilib system from as long as it does
			# 64-bits, we only need to know if the CPU we use is capable
			# of doing 64-bits mode
			[[ $(/usr/bin/isainfo | tr ' ' '\n' | wc -l) -ge 2 ]] \
				&& candomultilib=yes
			if [[ ${CHOST} == sparc* ]] ; then
				t64=sparcv9-${CHOST#*-}
				t32=sparc-${CHOST#*-}
			else
				t64=x86_64-${CHOST#*-}
				t32=i386-${CHOST#*-}
			fi
			;;
		# Even though multilib on Linux is often supported in some way,
		# it's hardly ever installed by default (it seems)
		# Since it's non-trivial to figure out if such system (binary
		# packages can report to be multilib, but lack all necessary
		# libs) is truely multilib capable, we don't bother here.  The
		# user can override if he/she is really convinced the system can
		# do it.
	esac
	if [[ ${candomultilib} == yes ]] ; then
		cat << EOF

Your system appears to be a multilib system, that is in fact also
capable of doing multilib right here, right now.  Multilib means
something like "being able to run multiple kinds of binaries".  The most
interesting kind for you now is 32-bits versus 64-bits binaries.  I can
create both a 32-bits as well as a 64-bits Prefix for you, but do you
actually know what I'm talking about here?  If not, just accept the
default here.  Honestly, you don't want to change it if you can't name
one advantage of 64-bits over 32-bits other than that 64 is a higher
number and when you buy a car or washing machine, you also always choose
the one with the highest number.
EOF
		[[ ${TODO} == 'noninteractive' ]] && ans="" ||
		case "${CHOST}" in
			x86_64-*|sparcv9-*)  # others can't do multilib, so don't bother
				# 64-bits native
				read -p "How many bits do you want your Prefix to target? [64] " ans
				;;
			*)
				# 32-bits native
				read -p "How many bits do you want your Prefix to target? [32] " ans
				;;
		esac
		case "${ans}" in
			"")
				: ;;
			32)
				CHOST=${t32}
				;;
			64)
				CHOST=${t64}
				;;
			*)
				cat << EOF

${ans}? Yeah Right(tm)!  You obviously don't know what you're talking
about, so I'll take the default instead.
EOF
				;;
		esac
	fi
	export CHOST

	# choose EPREFIX, we do this last, since we have to actually write
	# to the filesystem here to check that the EPREFIX is sane
	cat << EOF

Each and every Prefix has a home.  That is, a place where everything is
supposed to be in.  That place must be fully writable by you (duh), but
should also be able to hold some fair amount of data and preferably be
reasonably fast.  In terms of space, I advise something around 2GiB
(it's less if you're lucky).  I suggest a reasonably fast place because
we're going to compile a lot, and that generates a fair bit of IO.  If
some networked filesystem like NFS is the only option for you, then
you're just going to have to wait a fair bit longer.
This place which is your Prefix' home, is often referred to by a
variable called EPREFIX.
EOF
	while true ; do
		if [[ -z ${EPREFIX} ]] ; then
			# Make the default for Mac users a bit more "native feel"
			[[ ${CHOST} == *-darwin* ]] \
				&& EPREFIX=$HOME/Gentoo \
				|| EPREFIX=$HOME/gentoo
		fi
		echo
		[[ ${TODO} == 'noninteractive' ]] && ans=${ROOT} ||
		read -p "What do you want EPREFIX to be? [$EPREFIX] " ans
		case "${ans}" in
			"")
				: ;;
			/*)
				EPREFIX=${ans}
				;;
			*)
				echo
				echo "EPREFIX must be an absolute path!"
				[[ ${TODO} == 'noninteractive' ]] && exit 1
				EPREFIX=
				continue
				;;
		esac
		if [[ ! -d ${EPREFIX} ]] && ! mkdir -p "${EPREFIX}" ; then
			echo
			echo "It seems I cannot create ${EPREFIX}."
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "I'll forgive you this time, try again."
			EPREFIX=
			continue
		fi
		#readlink -f would not work on darwin, so use bash builtins
		local realEPREFIX="$(cd "$EPREFIX"; pwd -P)"
		if [[ -z ${I_KNOW_MY_GCC_WORKS_FINE_WITH_SYMLINKS} && ${EPREFIX} != ${realEPREFIX} ]]; then
			echo
			echo "$EPREFIX contains a symlink, which will make the merge of gcc"
			echo "imposible, use '${realEPREFIX}' instead or"
			echo "export I_KNOW_MY_GCC_WORKS_FINE_WITH_SYMLINKS='hell yeah'"
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "Have another try."
			EPREFIX="${realEPREFIX}"
			continue
		fi
		if ! touch "${EPREFIX}"/.canihaswrite >& /dev/null ; then
			echo
			echo "I cannot write to ${EPREFIX}!"
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "You want some fun, but without me?  Try another location."
			EPREFIX=
			continue
		fi
		# don't really expect this one to fail
		rm -f "${EPREFIX}"/.canihaswrite || exit 1
		# location seems ok
		break;
	done
	export PATH="$EPREFIX/usr/bin:$EPREFIX/bin:$EPREFIX/tmp/usr/bin:$EPREFIX/tmp/bin:${PATH}"

	cat << EOF

OK!  I'm going to give it a try, this is what I have collected sofar:
  EPREFIX=${EPREFIX}
  CHOST=${CHOST}
  PATH=${PATH}
  MAKEOPTS=${MAKEOPTS}

I'm now going to make an awful lot of noise going through a sequence of
stages to make your box as groovy as I am myself, setting up your
Prefix.  In short, I'm going to run stage1, stage2, stage3, followed by
emerge -e system.  If any of these stages fail, both you and me are in
deep trouble.  So let's hope that doesn't happen.
EOF
	echo
	[[ ${TODO} == 'noninteractive' ]] && ans="" ||
	read -p "Type here what you want to wish me [luck] " ans
	if [[ -n ${ans} && ${ans} != "luck" ]] ; then
		echo "Huh?  You're not serious, are you?"
		sleep 3
	fi
	echo

	if ! [[ -x ${EPREFIX}/usr/lib/portage/bin/emerge || -x ${EPREFIX}/tmp/usr/lib/portage/bin/emerge ]] && ! ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage1_log ; then
		# stage 1 fail
		cat << EOF

I tried running
  ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage1
but that failed :(  I have no clue, really.  Please find friendly folks
in #gentoo-prefix on irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list,
or file a bug at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
Sorry that I have failed you master.  I shall now return to my humble cave.
You can find a log of what happened in ${EPREFIX}/stage1.log
EOF
		exit 1
	fi

	# stage1 has set a profile, which defines CHOST, so unset any CHOST
	# we've got here to avoid cross-compilation due to slight
	# differences caused by our guessing vs. what the profile sets.
	# This happens at least on 32-bits Darwin, with i386 and i686.
	# https://bugs.gentoo.org/show_bug.cgi?id=433948
	unset CHOST
	export CHOST=$(portageq envvar CHOST)

	# after stage1 and stage2 we should have a bash of our own, which
	# is preferably over the host-provided one, because we know it can
	# deal with the bash-constructs we use in stage3 and onwards
	hash -r

	# new bash
	hash -r

	if ! bash ${BASH_SOURCE[0]} "${EPREFIX}" stage3_log ; then
		# stage 3 fail
		hash -r  # previous cat (tmp/usr/bin/cat) may have been removed
		cat << EOF

Hmmmm, I was already afraid of this to happen.  Running
  $(type -P bash) ${BASH_SOURCE[0]} "${EPREFIX}" stage3
somewhere failed :(  Details might be found in the build log:
EOF
		for log in "${EPREFIX}"{/tmp,}/var/tmp/portage/*/*/temp/build.log ; do
			[[ -e ${log} ]] || continue
			echo "  ${log}"
		done
		[[ -e ${log} ]] || echo "  (no build logs found?!?)"
		cat << EOF
I have no clue, really.  Please find friendly folks in #gentoo-prefix on
irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list, or file a bug
at bugs.gentoo.org under Gentoo/Alt, Prefix Support.  This is most
inconvenient, and it crushed my ego.  Sorry, I give up.
Should you want to give it a try, there is ${EPREFIX}/stage3.log
EOF
		exit 1
	fi

	hash -r  # tmp/* stuff is removed in stage3

	if ! bash ${BASH_SOURCE[0]} "${EPREFIX}" startscript ; then
		# startscript fail?
		cat << EOF

Ok, let's be honest towards each other.  If
  $(type -P bash) ${BASH_SOURCE[0]} "${EPREFIX}" startscript
fails, then who cheated on who?  Either you use an obscure shell, or
your PATH isn't really sane afterall.  Despite, I can't really
congratulate you here, you basically made it to the end.
Please find friendly folks in #gentoo-prefix on irc.gentoo.org,
gentoo-alt@lists.gentoo.org mailing list, or file a bug at
bugs.gentoo.org under Gentoo/Alt, Prefix Support.
It's sad we have to leave each other this way.  Just an inch away...
EOF
		exit 1
	fi

	echo
	cat << EOF

Woah!  Everything just worked!  Now YOU should run
  ${EPREFIX}/startprefix
and enjoy!  Thanks for using me, it was a pleasure to work with you.
EOF
}

## End Functions

## some vars

# We do not want stray $TMP, $TMPDIR or $TEMP settings
unset TMP TMPDIR TEMP

# Try to guess the CHOST if not set.  We currently only support guessing
# on a very sloppy base.
if [[ -z ${CHOST} ]]; then
	if [[ x$(type -t uname) == "xfile" ]]; then
		case `uname -s` in
			Linux)
				case `uname -m` in
					ppc*)
						CHOST="`uname -m | sed -e 's/^ppc/powerpc/'`-unknown-linux-gnu"
						;;
					powerpc*)
						CHOST="`uname -m`-unknown-linux-gnu"
						;;
					*)
						CHOST="`uname -m`-pc-linux-gnu"
						;;
				esac
				;;
			*)
				eerror "Nothing known about platform `uname -s`."
				eerror "Please set CHOST appropriately for your system"
				eerror "and rerun $0"
				exit 1
				;;
		esac
	fi
fi

MAKE=make

# Just guessing a prefix is kind of scary.  Hence, to make it a bit less
# scary, we force the user to give the prefix location here.  This also
# makes the script a bit less dangerous as it will die when just run to
# "see what happens".
if [[ -n $1 && -z $2 ]] ; then
	echo "usage: $0 [<prefix-path> <action>]"
	echo
	echo "Either you give no argument and I'll ask you interactively, or"
	echo "you need to give both the path offset for your Gentoo prefixed"
	echo "portage installation, and the action I should do there, e.g."
	echo "  $0 $HOME/prefix <action>"
	echo
	echo "See the source of this script for which actions exist."
	echo
	echo "$0: insufficient number of arguments" 1>&2
	exit 1
elif [[ -z $1 ]] ; then
	bootstrap_interactive
	exit 0
fi

ROOT="$1"

case $ROOT in
	chost.guess)
		# undocumented feature that sort of is our own config.guess, if
		# CHOST was unset, it now contains the guessed CHOST
		echo "$CHOST"
		exit 0
	;;
	/*) ;;
	*)
		echo "Your path offset needs to be absolute!" 1>&2
		exit 1
	;;
esac

export CXXFLAGS="${CXXFLAGS:-${CFLAGS}}"
export PORTDIR=${PORTDIR:-"${ROOT}/usr/portage"}
export DISTDIR=${DISTDIR:-"${PORTDIR}/distfiles"}
PORTAGE_TMPDIR=${PORTAGE_TMPDIR:-${ROOT}/tmp/var/tmp}
DISTFILES_URL=${DISTFILES_URL:-"http://dev.gentoo.org/~grobian/distfiles"}
SNAPSHOT_URL=${SNAPSHOT_URL:-"http://rsync.prefix.bitzolder.nl/snapshots"}
GNU_URL=${GNU_URL:="http://ftp.gnu.org/gnu"}
GENTOO_MIRRORS=${GENTOO_MIRRORS:="http://distfiles.gentoo.org"}
GCC_APPLE_URL="http://www.opensource.apple.com/darwinsource/tarballs/other"

export MAKE CONFIG_SHELL

mkdir -p /dev/shm/$USER/${ROOT##*/}

eval "$(modulecmd bash switch PrgEnv-cray PrgEnv-gnu)"
eval "$(modulecmd bash unload xalt)"
eval "$(modulecmd bash load cmake cray-hdf5 cray-netcdf cray-tpsl)"
export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig:${ROOT}/usr/share/pkgconfig:${PKG_CONFIG_PATH}"
export PATH="$EPREFIX/usr/bin:$EPREFIX/bin:$EPREFIX/tmp/usr/bin:$EPREFIX/tmp/bin:${PATH}"
#export CC=cc
#export CXX=CC
#export F77=ftn
#export F95=ftn
#export FC=ftn
export CRAYPE_LINK_TYPE=dynamic
export CRAY_ADD_RPATH=yes
export CC=gcc
export CXX=g++
export F77=gfortran
export F95=gfortran
export FC=gfortran

#export CRAY_CFLAGS="$(cc --cray-print-opts=cflags)"
#export CRAY_CFLAGS="$CRAY_CFLAGS $CRAY_BOOST_INCLUDE_OPTS"
#export CRAY_LDFLAGS="$(cc --cray-print-opts=libs)"
#LD_LIB_PATHS="$(echo $LD_LIBRARY_PATH | tr ':' '\n')"

#if [[ $(echo "$LD_LIB_PATHS" | wc -l) > 0 ]]
#then
#	while read -r path; do
#		LDP_LDFLAGS="$LDP_LDFLAGS -Wl,--rpath=$path" #,--enable-new-dtags"
#	done <<< "$LD_LIB_PATHS"
#fi
#export LDP_LDFLAGS="$LDP_LDFLAGS $CRAY_BOOST_POST_LINK_OPTS"

einfo "Bootstrapping Gentoo prefixed portage installation using"
einfo "host:   ${CHOST}"
einfo "prefix: ${ROOT}"

TODO=${2}
if [[ ${TODO} != "noninteractive" && $(type -t bootstrap_${TODO}) != "function" ]];
then
	eerror "bootstrap target ${TODO} unknown"
	exit 1
fi

einfo "ready to bootstrap ${TODO}"
# bootstrap_interactive proceeds with guessed defaults when TODO=noninteractive
bootstrap_${TODO#non} || exit 1
