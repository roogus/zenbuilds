# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="A plugin enabling the use of mypy in the Python LSP Server."
HOMEPAGE="https://github.com/python-lsp/pylsp-mypy"
SRC_URI="${HOMEPAGE}/archive/refs/tags/${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE=""

BDEPEND="

	>=dev-python/python-lsp-server-1.4.1[${PYTHON_USEDEP}]
	>=dev-python/mypy-0.950[${PYTHON_USEDEP}]
	>=dev-python/toml-0.10.2[${PYTHON_USEDEP}]
	>=dev-python/types-toml-0.10.7[${PYTHON_USEDEP}]
	>=dev-python/black-22.3.0[${PYTHON_USEDEP}]
	>=dev-python/pre-commit-2.19.0[${PYTHON_USEDEP}]
	>=dev-python/rstcheck-3.3.1[${PYTHON_USEDEP}]
	>=dev-python/isort-5.10.1-r1[${PYTHON_USEDEP}]
	test? (
		>=dev-python/pytest-7.1.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-cov-3.0.0-r1[${PYTHON_USEDEP}]
		>=dev-python/coverage-6.3.2-r1[${PYTHON_USEDEP}]
		>=dev-python/tox-3.25.0[${PYTHON_USEDEP}]
	)
"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest
