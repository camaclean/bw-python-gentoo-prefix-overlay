# Copyright 2015 University of Illinois
# Distributed under the terms of the GNU General Public License v3

EAPI=5

inherit eutils 

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DESCRIPTION="Eselect module for Environment Modules"

LICENSE="GPL-3"
SLOT="0"
IUSE="+extra-modules"

RDEPEND=">=app-admin/eselect-1.2.4
	 app-eselect/eselect-envmod"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_install() {
	insinto /etc/
	newins "${FILESDIR}"/selected.default-${PV} env-mod.conf
	insinto /usr/share/eselect/modules/
	newins "${FILESDIR}"/envmod-craype-arch.eselect-${PV} envmod-craype-arch.eselect
	newins "${FILESDIR}"/envmod-mpich.eselect-${PV} envmod-mpich.eselect
	newins "${FILESDIR}"/envmod-tpsl.eselect-${PV} envmod-tpsl.eselect
	newins "${FILESDIR}"/envmod-hdf5.eselect-${PV} envmod-hdf5.eselect
	newins "${FILESDIR}"/envmod-craype.eselect-${PV} envmod-craype.eselect
	newins "${FILESDIR}"/envmod-libsci.eselect-${PV} envmod-libsci.eselect
	dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-PrgEnv.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-boost.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-moab.eselect
	dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-hugepages.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-Base-opts.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-dmapp.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-xpmem.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-alps.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-modules.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-gni-headers.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-pgi.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cce.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-gcc.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-acml.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-intel.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-sdb.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-udreg.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-fftw.eselect
	dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-craype-target.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-pmi.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-ugni.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-torque.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cudatoolkit.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-xalt.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cmake.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cblas.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-boost.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-hypre.eselect
	dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-darshan.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-hss-llm.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cray-mpich-compat.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-valgrind.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-scripts.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-user-scripts.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-perfsuite.eselect
	dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-nodestat.eselect
	if use extra-modules ; then
		newins "${FILESDIR}"/envmod-ga.eselect-${PV} envmod-ga.eselect
		newins "${FILESDIR}"/envmod-lgdb.eselect-${PV} envmod-lgdb.eselect
		newins "${FILESDIR}"/envmod-shmem.eselect-${PV} envmod-shmem.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-account.eselect
		dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-ddt.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cray-mpich-abi.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cray-libsci_acc.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-nodehealth.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-ccm.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-atp.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-boot.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-codbc.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-dvs.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-rca.eselect
		dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-craype-network.eselect
		dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-craype-accel.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-batchlimit.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-configparse.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-configuration.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-dumpd.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-fcheck.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-csa.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-hosts.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-lustre-cray_gem_s.eselect
		dosym ../libs/envmod-fuzzy.bash /usr/share/eselect/modules/envmod-perftools.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-papi.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-hsn.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-job.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-sh.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-lustre-utils.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-swtools.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-xtpatch.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-switch.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-nic-compat.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-sysutils.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-pdsh.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-blcr.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cnrte.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-krca.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-iobuf.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-rur.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-shared-root.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-flexlm.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-projdb.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-chapel.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-init-service.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-lbcd.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-isvaccel.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-sysadm.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-crprep.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-rsipd.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cray-trilinos.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cray-ccdb.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-visit.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-craypkg-gen.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-wlm_detect.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-wlm_trans.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-java.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-R.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-ruby.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-flexnet-publisher.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-pathscale.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-gni-gpcdr-utils.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-install.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-stat.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-magma.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-profiler.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-tau.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-yt.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-msgsupport.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-mesa.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-forge.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-opengl.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-mercurial.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-logcb.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-mrnet.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-mxml.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-ibverbs.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-adios.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-szip.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-dummy.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-llm-utils.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-git.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-hdf4.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-gsl.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-cray-rsyslog.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-ptar.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-altd.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-likwid.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-onesided.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-mpip.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-motd-watch.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-paraview.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-szip.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-ntk.eselect
		dosym ../libs/envmod-exact.bash /usr/share/eselect/modules/envmod-ncsa-ca.eselect
	fi
}

pkg_postinst() {
	elog "Generating environment..."
	echo `which eselect`
	$EPREFIX/usr/bin/eselect envmod update
	env-update
	elog "Environment written to $EPREFIX/etc/env.d/01modules."
	elog "Source $EPREFIX/etc/profile to update shell environment."
	elog "\`. $EPREFIX/etc/profile\`"
}
