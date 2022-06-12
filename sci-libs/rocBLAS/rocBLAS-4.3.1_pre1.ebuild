# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

inherit cmake prefix python-any-r1

MY_PV="${PV%"_pre1"}"

DESCRIPTION="AMD's library for BLAS on ROCm."
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/rocBLAS"
#SRC_URI="https://github.com/ROCmSoftwarePlatform/rocBLAS/archive/rocm-${PV}.tar.gz -> rocm-${P}.tar.gz
#	https://github.com/ROCmSoftwarePlatform/Tensile/archive/rocm-${PV}.tar.gz -> rocm-Tensile-${PV}.tar.gz"
SRC_URI="https://github.com/ROCmSoftwarePlatform/rocBLAS/archive/refs/tags/rocm-${MY_PV}.tar.gz -> rocm-${PN}-${MY_PV}.tar.gz
	https://github.com/ROCmSoftwarePlatform/Tensile/archive/refs/tags/rocm-${MY_PV}.tar.gz -> rocm-Tensile-${MY_PV}.tar.gz"

S="${WORKDIR}"/${PN}-rocm-${MY_PV}

LICENSE="MIT"
KEYWORDS="~amd64"
IUSE="benchmark +gfx803 gfx900 gfx902 gfx906 gfx908 gfx1031 test"
REQUIRED_USE="|| ( gfx803 gfx900 gfx902 gfx906 gfx908 gfx1031 )"
SLOT="0/$(ver_cut 1-2)"

BDEPEND="
	dev-util/rocm-cmake
	!dev-util/Tensile
	$(python_gen_any_dep '
		dev-python/msgpack[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"

DEPEND="
	dev-util/hip:${SLOT}
	dev-libs/msgpack
	test? ( virtual/blas
		dev-cpp/gtest
		sys-libs/libomp )
	benchmark? ( virtual/blas
		sys-libs/libomp )
"
#RESTRICT="!test? ( test )"

python_check_deps() {
	has_version "dev-python/pyyaml[${PYTHON_USEDEP}]" &&
	has_version "dev-python/msgpack[${PYTHON_USEDEP}]"
}

PATCHES=("${FILESDIR}"/${PN}-4.3.0-fix-glibc-2.32-and-above.patch
	"${FILESDIR}"/${PN}-${MY_PV}-nueter-compilation-tests-script.patch
	"${FILESDIR}"/${PN}-${MY_PV}-change-default-Tensile-library-dir.patch
	"${FILESDIR}"/${PN}-4.3.0-link-system-blas.patch )

src_prepare() {
	eapply_user

	pushd "${WORKDIR}"/Tensile-rocm-${MY_PV} || die
	eapply "${FILESDIR}/Tensile-4.3.0-hsaco-compile-specified-arch.patch" # backported from upstream, should remove after 4.3.0
	eapply "${FILESDIR}/Tensile-4.3.0-output-commands.patch"
	eapply "${FILESDIR}/Tensile-4.3.1-enable-renoir-navi22.patch"
	popd || die

	# Fit for Gentoo FHS rule
	sed -e "/PREFIX rocblas/d" \
		-e "/<INSTALL_INTERFACE/s:include:include/rocblas:" \
		-e "s:rocblas/include:include/rocblas:" \
		-e "s:\\\\\${CPACK_PACKAGING_INSTALL_PREFIX}rocblas/lib:${EPREFIX}/usr/$(get_libdir)/rocblas:" \
		-e "s:share/doc/rocBLAS:share/doc/${PN}-${MY_PV}:" \
		-e "/rocm_install_symlink_subdir( rocblas )/d" -i library/src/CMakeLists.txt || die

	# Use setup.py to install Tensile rather than pip
	sed -r -e "/pip install/s:([^ \"\(]*python) -m pip install ([^ \"\)]*):\1 setup.py install --single-version-externally-managed --root / WORKING_DIRECTORY \2:g" -i cmake/virtualenv.cmake

	sed -e "s:,-rpath=.*\":\":" -i clients/CMakeLists.txt || die

	cmake_src_prepare
	eprefixify library/src/tensile_host.cpp
}

src_configure() {
	# allow acces to hardware
	addpredict /dev/kfd
	addpredict /dev/dri/
	addpredict /dev/random

	export PATH="${EPREFIX}/usr/lib/llvm/roc/bin:${PATH}"

	AMDGPU_TARGETS=""
	if use gfx803; then
		AMDGPU_TARGETS+="gfx803;"
	fi
	if use gfx900; then
		AMDGPU_TARGETS+="gfx900;"
	fi
	if use gfx902; then
		AMDGPU_TARGETS+="gfx902:xnack-;"
	fi
	if use gfx906; then
		AMDGPU_TARGETS+="gfx906;"
	fi
	if use gfx908; then
		AMDGPU_TARGETS+="gfx908;"
	fi
	if use gfx1031; then
		AMDGPU_TARGETS+="gfx1031;"
	fi


	local mycmakeargs=(
		-DTensile_LOGIC="asm_full"
		-DTensile_COMPILER="hipcc"
		-DTensile_LIBRARY_FORMAT="msgpack"
		-DTensile_CODE_OBJECT_VERSION="V3"
		-DTensile_TEST_LOCAL_PATH="${WORKDIR}/Tensile-rocm-${MY_PV}"
		-DBUILD_WITH_TENSILE=ON
		-DBUILD_WITH_TENSILE_HOST=ON
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_INSTALL_INCLUDEDIR="include/rocblas"
		-DCMAKE_SKIP_RPATH=TRUE
		-DBUILD_TESTING=$(usex test TRUE FALSE)
		-DBUILD_CLIENTS_SAMPLES=$(usex test ON OFF)
		-DBUILD_CLIENTS_TESTS=$(usex test ON OFF)
		-DBUILD_CLIENTS_BENCHMARKS=$(usex benchmark ON OFF)
		#${AMDGPU_TARGETS+-DAMDGPU_TARGETS="${AMDGPU_TARGETS}"}
		-DAMDGPU_TARGETS="${AMDGPU_TARGETS}"
		-D__skip_rocmclang="ON" ## fix cmake-3.21 configuration issue caused by officialy support programming language "HIP"
	)

	CXX="hipcc" cmake_src_configure

	# do not rerun cmake and the build process in src_install
	sed -e '/RERUN/,+1d' -i "${BUILD_DIR}"/build.ninja || die
}

check_rw_permission() {
	cmd="[ -r $1 ] && [ -w $1 ]"
	errormsg="${user} do not have read and write permissions on $1! \n Make sure ${user} is in render group and check the permissions."
	if has sandbox ${FEATURES}; then
		user=portage
		su portage -c "${cmd}" || die ${errormsg}
	else
		user=`whoami`
		${cmd} || die ${errormsg}
	fi
}

src_test() {
	# check permissions on /dev/kfd and /dev/dri/render*
	check_rw_permission /dev/kfd
	check_rw_permission /dev/dri/render*
	addwrite /dev/kfd
	addwrite /dev/dri/
	cd "${BUILD_DIR}/clients/staging" || die
	ROCBLAS_TENSILE_LIBPATH="${BUILD_DIR}/Tensile/library" ./rocblas-test
}

src_install() {
	cmake_src_install

	if use benchmark || use test; then
		cd "${BUILD_DIR}" || die
		dolib.so clients/librocblas_fortran_client.so
	fi

	if use benchmark; then
		cd "${BUILD_DIR}" || die
		dobin clients/staging/rocblas-bench
	fi

	if use test; then
		cd "${BUILD_DIR}" || die
		dobin clients/staging/rocblas-test
		dobin clients/staging/rocblas_gtest.data
	fi
}
