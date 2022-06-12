# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="A framework for managing multi-language pre-commit hooks."
HOMEPAGE="https://github.com/pre-commit/pre-commit"
SRC_URI="${HOMEPAGE}/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE="dev"

BDEPEND="

	>=dev-python/cfgv-3.3.1[${PYTHON_USEDEP}]
	>=dev-python/identify-2.4.12[${PYTHON_USEDEP}]
	>=dev-python/nodeenv-1.6.0[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0[${PYTHON_USEDEP}]
	>=dev-python/toml-0.10.2[${PYTHON_USEDEP}]
	>=dev-python/virtualenv-20.14.1-r1[${PYTHON_USEDEP}]
	dev? (
		>=dev-python/pytest-7.1.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-env-0.6.2[${PYTHON_USEDEP}]
		>=dev-python/coverage-6.3.2-r1[${PYTHON_USEDEP}]
		>=dev-python/distlib-0.3.4-r1[${PYTHON_USEDEP}]
		>=dev-python/re-assert-1.1.0[${PYTHON_USEDEP}]
		>=dev-python/covdefaults-2.2.0[${PYTHON_USEDEP}]
	)
	test? (
		>=dev-python/pytest-7.1.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-env-0.6.2[${PYTHON_USEDEP}]
		>=dev-python/coverage-6.3.2-r1[${PYTHON_USEDEP}]
		>=dev-python/distlib-0.3.4-r1[${PYTHON_USEDEP}]
		>=dev-python/re-assert-1.1.0[${PYTHON_USEDEP}]
		>=dev-python/covdefaults-2.2.0[${PYTHON_USEDEP}]
	)


"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest
