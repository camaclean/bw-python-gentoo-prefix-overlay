# Copyright 2015 University of Illinois
# Distributed under the terms of the GNU General Public License v3

EAPI=5

inherit eutils 

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DESCRIPTION="Eselect module for Environment Modules"

LICENSE="GPL-3"
SLOT="0"
IUSE="extra-modules"

RDEPEND=">=app-admin/eselect-1.2.4
	 app-eselect/eselect-envmod"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_install() {
	into /usr/share/eselect/modules/
	newins "${FILESDIR}"/envmod-craype-arch.eselect-${PV} envmod-craype-arch.eselect
	newins "${FILESDIR}"/envmod-mpich.eselect-${PV} envmod-mpich.eselect
	newins "${FILESDIR}"/envmod-tpsl.eselect-${PV} envmod-tpsl.eselect
	newins "${FILESDIR}"/envmod-hdf5.eselect-${PV} envmod-hdf5.eselect
	newins "${FILESDIR}"/envmod-craype.eselect-${PV} envmod-craype.eselect
	newins "${FILESDIR}"/envmod-libsci.eselect-${PV} envmod-libsci.eselect
	dosym ../libs/envmod-fuzzy.bash envmod-PrgEnv.eselect
	dosym ../libs/envmod-exact.bash envmod-boost.eselect
	dosym ../libs/envmod-exact.bash envmod-moab.eselect
	dosym ../libs/envmod-fuzzy.bash envmod-hugepages.eselect
	dosym ../libs/envmod-exact.bash envmod-Base-opts.eselect
	dosym ../libs/envmod-exact.bash envmod-dmapp.eselect
	dosym ../libs/envmod-exact.bash envmod-xpmem.eselect
	dosym ../libs/envmod-exact.bash envmod-alps.eselect
	dosym ../libs/envmod-exact.bash envmod-modules.eselect
	dosym ../libs/envmod-exact.bash envmod-gni-headers.eselect
	dosym ../libs/envmod-exact.bash envmod-pgi.eselect
	dosym ../libs/envmod-exact.bash envmod-cce.eselect
	dosym ../libs/envmod-exact.bash envmod-gcc.eselect
	dosym ../libs/envmod-exact.bash envmod-acml.eselect
	dosym ../libs/envmod-exact.bash envmod-intel.eselect
	dosym ../libs/envmod-exact.bash envmod-sdb.eselect
	dosym ../libs/envmod-exact.bash envmod-udreg.eselect
	dosym ../libs/envmod-exact.bash envmod-fftw.eselect
	dosym ../libs/envmod-fuzzy.bash envmod-craype-target.eselect
	dosym ../libs/envmod-exact.bash envmod-pmi.eselect
	dosym ../libs/envmod-exact.bash envmod-ugni.eselect
	dosym ../libs/envmod-exact.bash envmod-torque.eselect
	dosym ../libs/envmod-exact.bash envmod-cudatoolkit.eselect
	dosym ../libs/envmod-exact.bash envmod-xalt.eselect
	dosym ../libs/envmod-exact.bash envmod-cmake.eselect
	dosym ../libs/envmod-exact.bash envmod-cblas.eselect
	dosym ../libs/envmod-exact.bash envmod-boost.eselect
	dosym ../libs/envmod-exact.bash envmod-hypre.eselect
	dosym ../libs/envmod-fuzzy.bash envmod-darshan.eselect
	dosym ../libs/envmod-exact.bash envmod-hss-llm.eselect
	dosym ../libs/envmod-exact.bash envmod-cray-mpich-compat.eselect
	dosym ../libs/envmod-exact.bash envmod-valgrind.eselect
	dosym ../libs/envmod-exact.bash envmod-scripts.eselect
	dosym ../libs/envmod-exact.bash envmod-user-scripts.eselect
	dosym ../libs/envmod-exact.bash envmod-perfsuite.eselect
	if use extra-modules ; then
		newins "${FILESDIR}"/envmod-ga.eselect-${PV} envmod-ga.eselect
		newins "${FILESDIR}"/envmod-lgdb.eselect-${PV} envmod-lgdb.eselect
		newins "${FILESDIR}"/envmod-shmem.eselect-${PV} envmod-shmem.eselect
		dosym ../libs/envmod-exact.bash envmod-account.eselect
		dosym ../libs/envmod-fuzzy.bash envmod-ddt.eselect
		dosym ../libs/envmod-exact.bash envmod-cray-mpich-abi.eselect
		dosym ../libs/envmod-exact.bash envmod-cray-libsci_acc.eselect
		dosym ../libs/envmod-exact.bash envmod-nodehealth.eselect
		dosym ../libs/envmod-exact.bash envmod-nodestat.eselect
		dosym ../libs/envmod-exact.bash envmod-ccm.eselect
		dosym ../libs/envmod-exact.bash envmod-atp.eselect
		dosym ../libs/envmod-exact.bash envmod-boot.eselect
		dosym ../libs/envmod-exact.bash envmod-codbc.eselect
		dosym ../libs/envmod-exact.bash envmod-dvs.eselect
		dosym ../libs/envmod-exact.bash envmod-rca.eselect
		dosym ../libs/envmod-fuzzy.bash envmod-craype-network.eselect
		dosym ../libs/envmod-fuzzy.bash envmod-craype-accel.eselect
		dosym ../libs/envmod-exact.bash envmod-batchlimit.eselect
		dosym ../libs/envmod-exact.bash envmod-configparse.eselect
		dosym ../libs/envmod-exact.bash envmod-configuration.eselect
		dosym ../libs/envmod-exact.bash envmod-dumpd.eselect
		dosym ../libs/envmod-exact.bash envmod-fcheck.eselect
		dosym ../libs/envmod-exact.bash envmod-csa.eselect
		dosym ../libs/envmod-exact.bash envmod-hosts.eselect
		dosym ../libs/envmod-exact.bash envmod-lustre-cray_gem_s.eselect
		dosym ../libs/envmod-fuzzy.bash envmod-perftools.eselect
		dosym ../libs/envmod-exact.bash envmod-papi.eselect
		dosym ../libs/envmod-exact.bash envmod-hsn.eselect
		dosym ../libs/envmod-exact.bash envmod-job.eselect
		dosym ../libs/envmod-exact.bash envmod-sh.eselect
		dosym ../libs/envmod-exact.bash envmod-lustre-utils.eselect
		dosym ../libs/envmod-exact.bash envmod-swtools.eselect
		dosym ../libs/envmod-exact.bash envmod-xtpatch.eselect
		dosym ../libs/envmod-exact.bash envmod-switch.eselect
		dosym ../libs/envmod-exact.bash envmod-nic-compat.eselect
		dosym ../libs/envmod-exact.bash envmod-sysutils.eselect
		dosym ../libs/envmod-exact.bash envmod-pdsh.eselect
		dosym ../libs/envmod-exact.bash envmod-blcr.eselect
		dosym ../libs/envmod-exact.bash envmod-cnrte.eselect
		dosym ../libs/envmod-exact.bash envmod-krca.eselect
		dosym ../libs/envmod-exact.bash envmod-iobuf.eselect
		dosym ../libs/envmod-exact.bash envmod-rur.eselect
		dosym ../libs/envmod-exact.bash envmod-shared-root.eselect
		dosym ../libs/envmod-exact.bash envmod-flexlm.eselect
		dosym ../libs/envmod-exact.bash envmod-projdb.eselect
		dosym ../libs/envmod-exact.bash envmod-chapel.eselect
		dosym ../libs/envmod-exact.bash envmod-init-service.eselect
		dosym ../libs/envmod-exact.bash envmod-lbcd.eselect
		dosym ../libs/envmod-exact.bash envmod-isvaccel.eselect
		dosym ../libs/envmod-exact.bash envmod-sysadm.eselect
		dosym ../libs/envmod-exact.bash envmod-crprep.eselect
		dosym ../libs/envmod-exact.bash envmod-rsipd.eselect
		dosym ../libs/envmod-exact.bash envmod-cray-trilinos.eselect
		dosym ../libs/envmod-exact.bash envmod-cray-ccdb.eselect
		dosym ../libs/envmod-exact.bash envmod-visit.eselect
		dosym ../libs/envmod-exact.bash envmod-craypkg-gen.eselect
		dosym ../libs/envmod-exact.bash envmod-wlm_detect.sh
		dosym ../libs/envmod-exact.bash envmod-wlm_trans.sh
		dosym ../libs/envmod-exact.bash envmod-java.sh
	fi
}
