# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

# Full Blake2-256 hash
PKG_HASH_FULL="4d68db0ba16d416de7ad7846a36e3f9ba2a17850956172010edae054ec43a562"
PKG_HASH_FOR="4d"
PKG_HASH_MID="68"
PKG_HASH_AFT="db0ba16d416de7ad7846a36e3f9ba2a17850956172010edae054ec43a562"
DESCRIPTION="Typing stubs for docutils."
HOMEPAGE="https://pypi.org/project/types-docutils"
SRC_URI="https://files.pythonhosted.org/packages/${PKG_HASH_FOR}/${PKG_HASH_MID}/${PKG_HASH_AFT}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
