# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="Checks syntax of reStructuredText and code blocks nested within it"
HOMEPAGE="https://github.com/myint/rstcheck"
SRC_URI="${HOMEPAGE}/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE="doc dev"

BDEPEND="
	>=dev-python/poetry-core-1.0.0[${PYTHON_USEDEP}]
	<dev-python/docutils-0.19.0[${PYTHON_USEDEP}]
	<dev-python/types-docutils-0.19.0[${PYTHON_USEDEP}]
	<dev-python/pydantic-2.0.0[${PYTHON_USEDEP}]
	<dev-python/typer-5.0.0[${PYTHON_USEDEP}]
	>=dev-python/sphinx-5.0.0[${PYTHON_USEDEP}]
	<dev-python/tomli-3.0.0[${PYTHON_USEDEP}]
	doc? (
		>=dev-python/sphinx-autobuild-1.8.4[${PYTHON_USEDEP}]
		>=dev-python/m2r2-0.2.1[${PYTHON_USEDEP}]
		>=dev-python/sphinx-rtd-theme-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/sphinx-rtd-dark-mode-1.2.4[${PYTHON_USEDEP}]
		>=dev-python/sphinx-autodoc-typehints-1.15.0[${PYTHON_USEDEP}]
		>=dev-python/sphinx-contrib-apidoc-0.3.0[${PYTHON_USEDEP}]
		>=dev-python/sphinx-contrib-spelling-7.3.0[${PYTHON_USEDEP}]
		>=dev-python/sphinx-click-4.0.3[${PYTHON_USEDEP}]
	)
	dev? (
		>=dev-python/per-commit-2.17.0[${PYTHON_USEDEP}]
		>=dev-python/tox-3.15.0[${PYTHON_USEDEP}]
		>=dev-python/pylint-2.12.0[${PYTHON_USEDEP}]
		>=dev-python/mypy-0.931[${PYTHON_USEDEP}]
		>=dev-python/pytest-6.0.0[${PYTHON_USEDEP}]
		<dev-python/sphinx-5.0.0[${PYTHON_USEDEP}]
		>=dev-python/sphinx-rtd-theme-1.0.0[${PYTHON_USEDEP}]
	)
	test? (
		>=dev-python/pytest-6.0.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-cov-3.0.0[${PYTHON_USEDEP}]
		>=dev-python/coverage-6.0.0[${PYTHON_USEDEP}]
		>=dev-python/coverage-conditional-plugin-5.0.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-sugar-0.9.4-r1[${PYTHON_USEDEP}]
		>=dev-python/pytest-randomly-3.11.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-mock-3.7.0[${PYTHON_USEDEP}]
		>=dev-python/mock-4.0.0[${PYTHON_USEDEP}]
	)
"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest
