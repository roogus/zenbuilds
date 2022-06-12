# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="A tiny wrapper around builtin 'ast' and 'gast' packages."
HOMEPAGE="https://github.com/QuantStack/frilouz"
SRC_URI="${HOMEPAGE}/archive/refs/tags/${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE=""

BDEPEND="
	test? ( >=dev-python/pytest-7.1.2[${PYTHON_USEDEP}] )
"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest

#python_prepare_all() {
#	distutils-r1_python_prepare_all
#}
