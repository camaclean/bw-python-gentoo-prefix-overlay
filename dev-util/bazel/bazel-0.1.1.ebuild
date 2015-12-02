# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit multilib-build

DESCRIPTION="Google's Bazel build system"
HOMEPAGE="https://bazel.io"
if [[ ${PV} == 9999 ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/bazelbuild/bazel.git"
	inherit git-2
else
	SRC_URI="https://github.com/bazelbuild/bazel/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="cray examples"

RDEPEND=">=virtual/jdk-1.7.0
"
DEPEND="${RDEPEND}"

RESTRICT="strip"

src_prepare() {
	sed -i 's:#!/usr/bin/python:#!/usr/bin/env python:' ${S}/src/main/java/com/google/devtools/build/lib/bazel/rules/python/stub_template.txt
	sed -i "s:/usr/bin/gcc:$(which gcc):" tools/cpp/CROSSTOOL
	for flag in $LDFLAGS; do
		sed -i "123 i linker_flag: \"${flag}\"" third_party/gpus/crosstool/CROSSTOOL
	done
}

src_compile() {
	use cray && export JAVA_VERSION="$(echo $JAVA_VERSION | sed -ne 's:jdk\([0-9]\+\.[0-9]\+\)\.[0-9]\+_[0-9]\+:\1:p')"
	./compile.sh || die "Compilation failed!"
}

src_install() {
	mkdir -p "${ED}"/usr/share/bazel/base_workspace
        cp -r "${S}"/tools "${ED}"/usr/share/bazel/base_workspace/
        cp -r "${S}"/third_party "${ED}"/usr/share/bazel/base_workspace/
        use examples && cp -r "${S}"/examples "${ED}"/usr/share/bazel/base_workspace/
	mkdir -p "${ED}"/etc
        cat > "${ED}"/etc/bazel.rc <<EOF
build --package_path %workspace%:${EPREFIX}/usr/share/bazel/base_workspace
fetch --package_path %workspace%:${EPREFIX}/usr/share/bazel/base_workspace
query --package_path %workspace%:${EPREFIX}/usr/share/bazel/base_workspace
EOF
	mkdir -p "${ED}"/usr/bin
	cat > "${ED}"/usr/bin/bazel <<EOF
#!/bin/bash
"${EPREFIX}"/usr/libexec/bazel --bazelrc="${EPREFIX}"/etc/bazel.rc \$*
#command=\$1
#shift
#if [[ \$command == build ]] || [[ \$command == fetch ]] || [[ \$command == query ]]; then
#	"${EPREFIX}"/usr/libexec/bazel --bazelrc="${EPREFIX}"/etc/bazel.rc \$command \$*
#else
#	"${EPREFIX}"/usr/libexec/bazel \$command \$*
#fi
EOF
	if use cray; then
		chmod 775 "${ED}"/usr/bin/bazel
	else
		chmod 755 "${ED}"/usr/bin/bazel
	fi
	cd "$S"/output
	exeinto /usr/libexec
	doexe bazel
}
