# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A tool for debugging events on a Wayland window."
HOMEPAGE="https://git.sr.ht/~sircmpwn/wev"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://git.sr.ht/~sircmpwn/${PN}"
	KEYWORDS="~amd64 ~arm64 ~ppc64 ~riscv ~x86"
else
	SRC_URI="https://git.sr.ht/~sircmpwn/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm64 ~ppc64 ~riscv ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="
	>=dev-libs/wayland-1.20.0
	x11-libs/libxkbcommon
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-libs/wayland-protocols-1.25
	>=dev-util/wayland-scanner-1.15
	virtual/pkgconfig
	app-text/scdoc
"

pkg_preinst() {
	mv ${D}/usr/local/bin ${D}/usr/bin
	mv ${D}/usr/local/share ${D}/usr/share
	rm -rd ${D}/usr/local
}
