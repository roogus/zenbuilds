# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1 git-r3

DESCRIPTION="Handle cyclic relations compared by value."
HOMEPAGE="https://github.com/nerobin/cyclic"

EGIT_REPO_URI="${HOMEPAGE}.git"
EGIT_BRANCH="${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

BDEPEND=""

RDEPEND="${BDEPEND}"
