# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_PV="${PV%"_pre1"}"

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/RadeonOpenCompute/rocminfo/"
	inherit git-r3
else
	#SRC_URI="https://github.com/RadeonOpenCompute/rocminfo/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	SRC_URI="https://github.com/RadeonOpenCompute/rocminfo/archive/refs/tags/rocm-${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/rocminfo-rocm-${MY_PV}"
fi

DESCRIPTION="ROCm Application for Reporting System Info"
HOMEPAGE="https://github.com/RadeonOpenCompute/rocminfo"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

RDEPEND=">=dev-libs/rocr-runtime-${PV}"
DEPEND="${RDEPEND}"

PATCHES=("${FILESDIR}/${PN}-4.3.0-detect-builtin-amdgpu.patch")
