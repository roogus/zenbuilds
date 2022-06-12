# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

# Full Blake2-256 hash
PKG_HASH_FULL="c5daa5fb5c4eb663a1cd2d0c8ef619c42d51e6b8f55e155341e7b39b8c6c67b4"
PKG_HASH_FOR="c5"
PKG_HASH_MID="da"
PKG_HASH_AFT="a5fb5c4eb663a1cd2d0c8ef619c42d51e6b8f55e155341e7b39b8c6c67b4"
DESCRIPTION="Typing stubs for toml files."
HOMEPAGE="https://pypi.org/project/types-toml"
SRC_URI="https://files.pythonhosted.org/packages/${PKG_HASH_FOR}/${PKG_HASH_MID}/${PKG_HASH_AFT}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE=""

BDEPEND=""

RDEPEND="${BDEPEND}"

