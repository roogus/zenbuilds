# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="A tool to detect the surrounding shell."
HOMEPAGE="https://github.com/sarugaku/shellingham"
SRC_URI="${HOMEPAGE}/archive/refs/tags/${PV}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

BDEPEND=">=dev-python/wheel-0.37.1-r1[${PYTHON_USEDEP}]"

RDEPEND="${BDEPEND}"
