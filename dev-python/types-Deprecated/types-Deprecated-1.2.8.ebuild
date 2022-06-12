# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

# Full Blake2-256 hash
PKG_HASH_FULL="45e83d4a0aa5eb532eff1f94b7b2eaadbdfd7684db3c623d9d4b758442bb8147"
PKG_HASH_FOR="45"
PKG_HASH_MID="e8"
PKG_HASH_AFT="3d4a0aa5eb532eff1f94b7b2eaadbdfd7684db3c623d9d4b758442bb8147"
DESCRIPTION="Typing stubs for deprecated apis."
HOMEPAGE="https://pypi.org/project/types-Deprecated"
SRC_URI="https://files.pythonhosted.org/packages/${PKG_HASH_FOR}/${PKG_HASH_MID}/${PKG_HASH_AFT}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

IUSE=""

BDEPEND=""

RDEPEND="${BDEPEND}"

