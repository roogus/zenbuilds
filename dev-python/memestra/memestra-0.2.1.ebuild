# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="A static analysis tool which detects the use of deprecated APIs."
HOMEPAGE="https://github.com/QuantStack/memestra"
SRC_URI="${HOMEPAGE}/archive/refs/tags/${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE=""

BDEPEND="
	>=dev-python/gast-0.5.3[${PYTHON_USEDEP}]
	>=dev-python/beniget-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/nbformat-5.4.0[${PYTHON_USEDEP}]
	>=dev-python/nbconvert-6.4.5[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
	>=dev-python/frilouz-0.0.2[${PYTHON_USEDEP}]
	test? ( >=dev-python/pytest-7.1.2[${PYTHON_USEDEP}] )
"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest

#python_prepare_all() {
#	distutils-r1_python_prepare_all
#}
