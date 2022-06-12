# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

DESCRIPTION="Extended refactoring capabilities for Python LSP Server using Rope."
HOMEPAGE="https://github.com/python-rope/pylsp-rope"
SRC_URI="${HOMEPAGE}/archive/refs/tags/${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE="dev"

BDEPEND="

	>=dev-python/python-lsp-server-1.4.1[${PYTHON_USEDEP}]
	>=dev-python/rope-1.0.0[${PYTHON_USEDEP}]
	dev? (
		>=dev-python/build-0.7.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-7.1.2[${PYTHON_USEDEP}]
		>=dev-python/twine-4.0.0[${PYTHON_USEDEP}]
	)
	test? ( >=dev-python/pytest-7.1.2[${PYTHON_USEDEP}] )
"

RDEPEND="${BDEPEND}"

distutils_enable_tests pytest

src_install() {
	# Package installs 'test' package which is forbidden and
	# likely a bug in the build system.
	# Remove those test directories.
	IFS_PRE="${IFS}"
	IFS=$'\n'
	DIRS=( $(find "${WORKDIR}" -type d -name test) )
	for d in "${DIRS[@]}"
	do
		rm -rfd "${d}" || die
	done
	IFS="${IFS_PRE}"

	default
}
