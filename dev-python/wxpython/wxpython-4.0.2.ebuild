# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python{2_7,3_{4,5,6}} )
WX_GTK_VER="3.0-gtk3"

inherit alternatives distutils-r1 eutils fdo-mime flag-o-matic wxwidgets

MY_PN="wxPython"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A blending of the wxWindows C++ class library with Python"
HOMEPAGE="http://www.wxpython.org/"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="wxWinLL-3"
SLOT="4.0"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="cairo examples libnotify opengl"

RDEPEND="
        dev-lang/python-exec:2[${PYTHON_USEDEP}]
        >=x11-libs/wxGTK-3.0.4:${WX_GTK_VER}=[libnotify=,opengl?,tiff,X]
        dev-libs/glib:2
        dev-python/setuptools[${PYTHON_USEDEP}]
        media-libs/libpng:0=
        media-libs/tiff:0
        virtual/jpeg
        x11-libs/gtk+:3
        x11-libs/pango[X]
        cairo?  ( >=dev-python/pycairo-1.8.4[${PYTHON_USEDEP}] )
        opengl? ( dev-python/pyopengl[${PYTHON_USEDEP}] )"

DEPEND="${RDEPEND}
        virtual/pkgconfig"

S="${WORKDIR}/${MY_PN}-${PV}"
DOC_S="${WORKDIR}/wxPython-${PV}"

# The hacky build system seems to be broken with out-of-source builds,
# and installs 'wx' package globally.
DISTUTILS_IN_SOURCE_BUILD=1

python_prepare_all() {
        sed -i "s:self.cflags.append('-O3'):pass:" buildtools/config.py || die "sed failed"

        cd "${S}"
        distutils-r1_python_prepare_all
}

src_configure() {
        need-wxwidgets unicode

        mydistutilsargs=(
                WX_CONFIG="${WX_CONFIG}"
                WXPORT=gtk3
        )
}

python_compile() {
        # We need to have separate libdirs due to hackery, bug #455332.
        distutils-r1_python_compile #\
        #        build --build-purelib "${BUILD_DIR}"/lib.common
}

python_install() {
        distutils-r1_python_install #\
        #        build --build-purelib "${BUILD_DIR}"/lib.common

        # adjust the filenames for wxPython slots.
        local file
        cp "${FILESDIR}"/wxpython-4.0-wxversion.py "${D}"$(python_get_sitedir)/wxversion.py || die
        echo "wx-4.0-gtk3" > "${D}"$(python_get_sitedir)/wx.pth || die

        for file in "${D}$(python_get_sitedir)"/wx{version.*,.pth}
	do
                mv "${file}" "${file}-${SLOT}" || die
	done
        cd "${D}"$(python_get_sitedir) || die
        mv wx wx-4.0-gtk3 || die
        cd "${ED}"usr/lib/python-exec/"${EPYTHON}" || die
        for file in *; do
                mv "${file}" "${file}-${SLOT}" || die

                # wrappers are common to all impls, so a parallel run may
                # move it for us. ln+rm is more failure-proof.
                ln -fs ../lib/python-exec/python-exec2 "${ED}usr/bin/${file}-${SLOT}" || die
                rm -f "${ED}usr/bin/${file}"
        done
}

python_install_all() {
        dodoc {CHANGES,README}.rst

        newicon wx/py/PyCrust_32.png PyCrust-${SLOT}.png
        newicon wx/py/PySlices_32.png PySlices-${SLOT}.png

        if use examples; then
                docinto demo
                dodoc -r "${DOC_S}"/demo/.
                docinto samples
                dodoc -r "${DOC_S}"/samples/.

                [[ -e ${docdir}/samples/embedded/embedded ]] \
                        && rm -f "${docdir}"/samples/embedded/embedded

                docompress -x /usr/share/doc/${PF}/{demo,samples}
        fi
        distutils-r1_python_install_all
}

pkg_postinst() {
        fdo-mime_desktop_database_update

        create_symlinks() {
                alternatives_auto_makesym "$(python_get_sitedir)/wx.pth" "$(python_get_sitedir)/wx.pth-[0-9].[0-9]"
                alternatives_auto_makesym "$(python_get_sitedir)/wxversion.py" "$(python_get_sitedir)/wxversion.py-[0-9].[0-9]"
        }
        python_foreach_impl create_symlinks

        echo
        elog "Gentoo uses the Multi-version method for SLOT'ing."
        elog "Developers, see this site for instructions on using"
        elog "it with your apps:"
        elog "http://wiki.wxpython.org/MultiVersionInstalls"
        if use examples; then
                echo
                elog "The demo.py app which contains demo modules with"
                elog "documentation and source code has been installed at"
                elog "/usr/share/doc/${PF}/demo/demo.py"
                echo
                elog "More example apps and modules can be found in"
                elog "/usr/share/doc/${PF}/samples/"
        fi
}

pkg_postrm() {
        fdo-mime_desktop_database_update

        update_symlinks() {
                alternatives_auto_makesym "$(python_get_sitedir)/wx.pth" "$(python_get_sitedir)/wx.pth-[0-9].[0-9]"
                alternatives_auto_makesym "$(python_get_sitedir)/wxversion.py" "$(python_get_sitedir)/wxversion.py-[0-9].[0-9]"
        }
        python_foreach_impl update_symlinks
}
