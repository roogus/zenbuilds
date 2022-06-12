# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="A library for build CLI applications."
HOMEPAGE="https://github.com/tiangolo/typer"
SRC_URI="${HOMEPAGE}/archive/refs/tags/${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE="dev doc"

BDEPEND="
	>=dev-python/flit_core-3.0.0[${PYTHON_USEDEP}]
	<dev-python/click-9.0.0[${PYTHON_USEDEP}]
	<dev-python/shellingham-2.0.0[${PYTHON_USEDEP}]
	<dev-python/colorama-0.5.0[${PYTHON_USEDEP}]
	doc? (
		<dev-python/mkdocs-2.0.0[${PYTHON_USEDEP}]
		<dev-python/mkdocs-material-9.0.0[${PYTHON_USEDEP}]
		<dev-python/mdx-include-2.0.0[${PYTHON_USEDEP}]
	)
	dev? (
		<dev-python/autoflake-2.0.0[${PYTHON_USEDEP}]
		<dev-python/flake8-4.0.0[${PYTHON_USEDEP}]
		<dev-python/pre-commit-3.0.0[${PYTHON_USEDEP}]
	)
	test? (
		<dev-python/shellingham-2.0.0[${PYTHON_USEDEP}]
		<dev-python/pytest-5.4.0[${PYTHON_USEDEP}]
		<dev-python/pytest-cov-3.0.0[${PYTHON_USEDEP}]
		<dev-python/coverage-6.0.0[${PYTHON_USEDEP}]
		<dev-python/pytest-xdist-2.0.0[${PYTHON_USEDEP}]
		<dev-python/pytest-sugar-0.10.0[${PYTHON_USEDEP}]
		=dev-python/mypy-0.910[${PYTHON_USEDEP}]
		<dev-python/black-23.0.0[${PYTHON_USEDEP}]
		<dev-python/isort-6.0.0[${PYTHON_USEDEP}]
	)
"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest
