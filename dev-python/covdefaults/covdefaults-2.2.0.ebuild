# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION=""
HOMEPAGE="https://github.com/asottile/covdefaults"
SRC_URI="${HOMEPAGE}/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE=""

BDEPEND="
	>=dev-python/coverage-6.3.2-r1[${PYTHON_USEDEP}]
	test? ( >=dev-python/pytest-7.1.2[${PYTHON_USEDEP}] )
"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest
