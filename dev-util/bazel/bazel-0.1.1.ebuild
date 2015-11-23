# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit multilib-build git-2

DESCRIPTION="Google's Bazel build system"
HOMEPAGE="https://bazel.io"
SRC_URI=""
EGIT_REPO_URI="https://github.com/bazelbuild/bazel.git"
if [[ ${PV} != 9999 ]]; then
	EGIT_COMMIT="${PV}"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="cray"

RDEPEND=">=virtual/jdk-1.7.0
"
DEPEND="${RDEPEND}"

RESTRICT="strip"

src_prepare() {
	sed -i 's:#!/usr/bin/python:#!/usr/bin/env python:' ${S}/src/main/java/com/google/devtools/build/lib/bazel/rules/python/stub_template.txt
	sed -i "s:/usr/bin/gcc:$(which gcc):" tools/cpp/CROSSTOOL
}

src_compile() {
	use cray && export JAVA_VERSION="$(echo $JAVA_VERSION | sed -ne 's:jdk\([0-9]\+\.[0-9]\+\)\.[0-9]\+_[0-9]\+:\1:p')"
	./compile.sh
}

src_install() {
	cd "$S"/output
	exeinto /usr/bin
	doexe bazel
}
