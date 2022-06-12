# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Extension for visualizing asusctl-ctrl(asusd) settings and status."
HOMEPAGE="https://gitlab.com/asus-linux/asusctl-gex"
SRC_URI="https://gitlab.com/asus-linux/asusctl-gex/-/jobs/1342979938/artifacts/download -> ${P}.zip"
S="${WORKDIR}/asusctl-gex@asus-linux.org"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	>=gnome-base/gnome-shell-3.36
	app-eselect/eselect-gnome-shell-extensions
	!!gnome-extra/gnome-shell-extension-asus-nb-gex
"
DEPEND="${RDEPEND}
	dev-libs/glib:2
"

src_install() {
	insinto /usr/share/gnome-shell/extensions/asusctl-gex@asus-linux.org
	doins -r ${S}/*
}

pkg_postinst() {
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}
