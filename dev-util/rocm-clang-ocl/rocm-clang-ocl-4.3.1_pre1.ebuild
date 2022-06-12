# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_PV="${PV%"_pre1"}"

DESCRIPTION="OpenCL compilation with clang compiler"
HOMEPAGE="https://github.com/RadeonOpenCompute/clang-ocl.git"
#SRC_URI="https://github.com/RadeonOpenCompute/clang-ocl/archive/rocm-${PV}.tar.gz -> rocm-clang-ocl-${PV}.tar.gz"
SRC_URI="https://github.com/RadeonOpenCompute/clang-ocl/archive/refs/tags/rocm-${MY_PV}.tar.gz -> rocm-clang-ocl-${MY_PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND=">=dev-libs/rocm-opencl-runtime-${PV}"
DEPEND="
	>=dev-util/rocm-cmake-${PV}
	${RDEPEND}"

S="${WORKDIR}/clang-ocl-rocm-${MY_PV}"

src_prepare() {
	sed -e "s:HINTS \${CXX_COMPILER_PATH}/bin:NO_DEFAULT_PATH:" \
		-e "s:/opt/rocm/llvm/bin:${EPREFIX}/usr/lib/llvm/roc/bin:" \
		-e "/AMDDeviceLibs PATHS/s:/opt/rocm:${EPREFIX}/usr/lib/cmake/AMDDeviceLibs:" \
		-e "s:\${AMD_DEVICE_LIBS_PREFIX}/amdgcn/bitcode:${EPREFIX}/usr/lib/amdgcn/bitcode:" \
		-i CMakeLists.txt || die

	cmake_src_prepare
}
