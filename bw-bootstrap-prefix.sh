#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 EPREFIX"
	exit 1
fi

module switch PrgEnv-cray PrgEnv-gnu

export EPREFIX="$1"

export PATH="$EPREFIX/usr/bin:$EPREFIX/bin:$EPREFIX/tmp/usr/bin:$EPREFIX/tmp/bin:/usr/bin:/bin"
unset LD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH
set PKG_CONFIG_PATH_BAK="$PKG_CONFIG_PATH"
unset PKG_CONFIG_PATH

#Download bootstrap script and set stage1 configs on the first run
if [ ! -f "$EPREFIX/.stage1_config_set" ]; then
	wget http://rsync.prefix.bitzolder.nl/scripts/bootstrap-prefix.sh
	chmod +x bootstrap-prefix.sh

	#Ignore the big provided packages for the stage1 bootstrap
	mkdir -p $EPREFIX/tmp/etc/portage/profile
	echo "sys-devel/gcc-4.7.3" >> $EPREFIX/tmp/etc/portage/profile/package.provided
	echo "sys-devel/binutils-2.24" >> $EPREFIX/tmp/etc/portage/profile/package.provided
	touch "$EPREFIX/.stage1_config_set"
else
	echo "Stage 1 config already set. Skipping."
fi

#Bootstrap stage 1
if [ ! -f "$EPREFIX/.stage1_built" ]; then
	./bootstrap-prefix.sh $EPREFIX stage1 || exit 1
	touch "$EPREFIX/.stage1_built"
else
	echo "Stage 1 already built. Skipping."
fi

#Fetch the latest portage tree, rather than a snapshot
export LATEST_TREE_YES=1

#Always make sure that build directories (still) exit
mkdir -p /dev/shm/$USER/build{1,2}
ln -snf /dev/shm/$USER/build1 $EPREFIX/tmp/var/tmp/portage
ln -snf /dev/shm/$USER/build2 $EPREFIX/var/tmp/portage

#Set stage2/3 configs on the first run
if [ ! -f "$EPREFIX/.stage2_config_set" ]; then
	git clone https://github.com/camaclean/bw-python-gentoo-prefix-overlay.git $EPREFIX/usr/local/bw-python-gentoo-prefix-overlay
	sed -i 's|^CFLAGS=".*"|CFLAGS="$\{CFLAGS\} -O2 -pipe -march=native -I$EPREFIX/usr/include -I/usr/include -L$EPREFIX/lib -L$EPREFIX/usr/lib -L/lib64 -L/usr/lib64"|' $EPREFIX/etc/portage/make.conf
	sed -i 's|^MAKEOPTS=".*"|MAKEOPTS="-j9"|' $EPREFIX/etc/portage/make.conf
	sed -i 's|^MAKEOPTS=".*"|MAKEOPTS="-j9"|' $EPREFIX/tmp/etc/portage/make.conf
	echo 'LDFLAGS="${LDFLAGS} -Wl,--rpath=$EPREFIX/lib -Wl,--rpath=$EPREFIX/usr/lib"' >> $EPREFIX/etc/portage/make.conf
	mkdir -p $EPREFIX/etc/portage/repos.conf
	echo '[BWGentooPrefix]' >> $EPREFIX/etc/portage/repos.conf/bwgp.conf
	echo "location = $EPREFIX/usr/local/bw-python-gentoo-prefix-overlay" >> $EPREFIX/etc/portage/repos.conf/bwgp.conf
	echo 'masters = gentoo' >> $EPREFIX/etc/portage/repos.conf/bwgp.conf
	echo 'sync-type = git' >> $EPREFIX/etc/portage/repos.conf/bwgp.conf
	echo 'sync-uri = https://github.com/camaclean/bw-python-gentoo-prefix-overlay.git' >> $EPREFIX/etc/portage/repos.conf/bwgp.conf
	echo 'auto-sync = yes' >> $EPREFIX/etc/portage/repos.conf/bwgp.conf
	ln -snf $EPREFIX/usr/local/bw-python-gentoo-prefix-overlay/profiles/prefix/linux/amd64-bw $EPREFIX/tmp/etc/portage/make.profile
	ln -snf $EPREFIX/usr/local/bw-python-gentoo-prefix-overlay/profiles/prefix/linux/amd64-bw $EPREFIX/etc/portage/make.profile
	cp -r $EPREFIX/usr/local/bw-python-gentoo-prefix-overlay/profiles/prefix/linux/amd64-bw/env $EPREFIX/etc/portage/
	cp $EPREFIX/usr/local/bw-python-gentoo-prefix-overlay/profiles/prefix/linux/amd64-bw/package.env $EPREFIX/etc/portage/
	touch "$EPREFIX/.stage2_config_set"
else
	echo "Stage 2 config already set. Updating overlay."
	cd $EPREFIX/usr/local/bw-python-gentoo-prefix-overlay/
	git pull
	cd -
fi
if [ ! -f "$EPREFIX/.stage2_built" ]; then
	./bootstrap-prefix.sh $EPREFIX stage2 || exit 1
	touch "$EPREFIX/.stage2_built"
else
	echo "Stage 2 already built. Skipping."
fi

if [ ! -f "$EPREFIX/.stage3_built" ]; then
	./bootstrap-prefix.sh $EPREFIX stage3 || exit 1
	touch "$EPREFIX/.stage3_built"
else
	echo "Stage 3 already built. Skipping."
fi

if [ ! -f "$EPREFIX/startprefix" ]; then
	./bootstrap-prefix.sh $EPREFIX startscript
	cd $EPREFIX
	patch -p0 <<EOT
*** startprefix Thu Aug 27 08:26:28 2015
--- startprefix Wed Aug 26 14:34:31 2015
***************
*** 12,17 ****
--- 12,19 ----
  # env -i HOME=\$HOME TERM=\$TERM USER=\$USER \$SHELL -l
  # hence this script starts the Prefix shell like this
  
+ export HOST_PATH=\$PATH
+ 
  # What is our prefix?
  EPREFIX="/u/staff/cmaclean/test2"
  
*************** echo "Entering Gentoo Prefix \${EPREFIX}"
*** 38,44 ****
  # start the login shell, clean the entire environment but what's needed
  # PROFILEREAD is necessary on SUSE not to wipe the env on shell start
  [[ -n \${PROFILEREAD} ]] && DOPROFILEREAD="PROFILEREAD=\${PROFILEREAD}"
! env -i HOME=\$HOME TERM=\$TERM USER=\$USER SHELL=\$SHELL \$DOPROFILEREAD \$SHELL -l
  # and leave a message when we exit... the shell might return non-zero
  # without having real problems, so don't send alarming messages about
  # that
--- 40,46 ----
  # start the login shell, clean the entire environment but what's needed
  # PROFILEREAD is necessary on SUSE not to wipe the env on shell start
  [[ -n \${PROFILEREAD} ]] && DOPROFILEREAD="PROFILEREAD=\${PROFILEREAD}"
! env -i HOME=\$HOME TERM=\$TERM USER=\$USER SHELL=\$SHELL HOST_PATH=\$HOST_PATH \$DOPROFILEREAD \$SHELL -l
  # and leave a message when we exit... the shell might return non-zero
  # without having real problems, so don't send alarming messages about
  # that
EOT
	cd -
	echo 'export PATH="$PATH:$HOST_PATH"' >> $EPREFIX/etc/profile

fi

if [ ! -f "$EPREFIX/.rebuilt" ]; then
	emerge -ve world || exit 1
	touch "$EPREFIX/.rebuilt"
fi
