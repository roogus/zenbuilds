# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 toolchain-funcs xdg-utils

DESCRIPTION="The missing terminal file browser for X"
HOMEPAGE="https://github.com/jarun/nnn"
SRC_URI="https://github.com/jarun/nnn/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc64 ~x86"
IUSE="-debug +readline pcre +locale +gpm +batch-renamer +fifo-previewer -ctx8 -icons"
IUSE="${IUSE} -nerdfont -emoji -qsort -bench-mode +session +usr-grp-status X -allow-empty-filters"
IUSE="${IUSE} +sort-dir-contents git-status name-first restore-preview"

DEPEND="sys-libs/ncurses:0=
	sys-libs/readline:0="
RDEPEND="${DEPEND}"

src_prepare() {
	default
	tc-export CC
	sed -i -e '/install: all/install:/' Makefile || die "sed failed"
}

src_compile() {
	_DEBUG=$(usex debug O_DEBUG=1 O_DEBUG=0)
	_NORL=$(usex readline O_NORL=0 O_NORL=1)
	_PCRE=$(usex pcre O_PCRE=1 O_PCRE=0)
	_NOLC=$(usex locale O_NOLC=0 O_NOLC=1)
	_NOMOUSE=$(usex gpm O_NOMOUSE=0 O_NOMOUSE=1)
	_NOBATCH=$(usex batch-renamer O_NOBATCH=0 O_NOBATCH=1)
	_NOFIFO=$(usex fifo-previewer O_NOFIFO=0 O_NOFIFO=1)
	_CTX8=$(usex ctx8 O_CTX8=1 O_CTX8=0)
	_ICONS=$(usex icons O_ICONS=1 O_ICONS=0)
	_NERD=$(usex nerdfont O_NERD=1 O_NERD=0)
	_EMOJI=$(usex emoji O_EMOJI=1 O_EMOJI=0)
	_QSORT=$(usex qsort O_QSORT=1 O_QSORT=0)
	_BENCH=$(usex bench-mode O_BENCH=1 O_BENCH=0)
	_NOSSN=$(usex session O_NOSSN=0 O_NOSSN=1)
	_NOUG=$(usex usr-grp-status O_NOUG=0 O_NOUG=1)
	_NOX11=$(usex X O_NOX11=0 O_NOX11=1)
	_MATCHFLTR=$(usex allow-empty-filters O_MATCHFLTR=1 O_MATCHFLTR=0)
	_NOSORT=$(usex sort-dir-contents O_NOSORT=0 O_NOSORT=1)
	_GITSTATUS=$(usex git-status O_GITSTATUS=1 O_GITSTATUS=0)
	_NAMEFIRST=$(usex name-first O_NAMEFIRST=1 O_NAMEFIRST=0)
	_RESTOREPREVIEW=$(usex restore-preview O_RESTOREPREVIEW=1 O_RESTOREPREVIEW=0)

emake "${_DEBUG}" "${_NORL}" "${_PCRE}" "${_NOLC}" "${_NOMOUSE}" "${_NOBATCH}" "${_NOFIFO}" "${_CTX8}" "${_ICONS}" "${_NERD}" "${_EMOJI}" "${_QSORT}" "${_BENCH}" "${_NOSSN}" "${_NOUG}" "${_NOX11}" "${_MATCHFLTR}" "${_NOSORT}" "${_GITSTATUS}" "${_NAMEFIRST}" "${_RESTOREPREVIEW}"

}

src_install() {
	emake PREFIX="${EPREFIX}/usr" DESTDIR="${D}" install

	emake PREFIX="${EPREFIX}/usr" DESTDIR="${D}" install-desktop

	newbashcomp misc/auto-completion/bash/nnn-completion.bash nnn

	insinto /usr/share/fish/vendor_completions.d
	doins misc/auto-completion/fish/nnn.fish

	insinto /usr/share/zsh/site-functions
	doins misc/auto-completion/zsh/_nnn

	einstalldocs
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
