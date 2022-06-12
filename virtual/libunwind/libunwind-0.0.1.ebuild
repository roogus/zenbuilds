# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for libunwind"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64 ~ppc ~ppc64 ~riscv"
IUSE="llvm"

BDEPEND=""
RDEPEND="!llvm? ( sys-libs/libunwind ) llvm? ( sys-libs/llvm-libunwind )"

# These pkgs depend on sys-libs/libunwind:
# dev-cpp/glog-0.4.0 (sys-libs/libunwind[abi_x86_32(-)?,abi_x86_64(-)?,abi_x86_x32(-)?,abi_mips_n32(-)?,abi_mips_n64(-)?,abi_mips_o32(-)?,abi_s390_32(-)?,abi_s390_64(-)?])
# dev-lang/mono-6.12.0.122 (ia64 ? sys-libs/libunwind)
# dev-lang/ocaml-4.11.2-r2 (spacetime ? sys-libs/libunwind)
# dev-lang/rust-1.58.1 (elibc_musl ? sys-libs/libunwind)
# media-gfx/gimp-2.10.28-r1 (unwind ? >=sys-libs/libunwind-1.1.0)
# media-libs/gstreamer-1.18.4 (unwind ? >=sys-libs/libunwind-1.2_rc1[abi_x86_32(-)?,abi_x86_64(-)?,abi_x86_x32(-)?,abi_mips_n32(-)?,abi_mips_n64(-)?,abi_mips_o32(-)?,abi_s390_32(-)?,abi_s390_64(-)?])
# media-libs/mesa-21.3.5 (unwind ? sys-libs/libunwind[abi_x86_32(-)?,abi_x86_64(-)?,abi_x86_x32(-)?,abi_mips_n32(-)?,abi_mips_n64(-)?,abi_mips_o32(-)?,abi_s390_32(-)?,abi_s390_64(-)?])
# net-fs/samba-4.15.3-r1 (!sparc ? sys-libs/libunwind)
# net-libs/zeromq-4.3.4-r1 (unwind ? sys-libs/libunwind)
# sys-devel/clang-13.0.0 (!llvm-libunwind ? sys-libs/libunwind)
# sys-libs/libcxxabi-13.0.0 (libunwind ? >=sys-libs/libunwind-1.0.1-r1[static-libs?,abi_x86_32(-)?,abi_x86_64(-)?,abi_x86_x32(-)?,abi_mips_n32(-)?,abi_mips_n64(-)?,abi_mips_o32(-)?,abi_s390_32(-)?,abi_s390_64(-)?])
# sys-process/htop-3.1.2-r1 (!llvm-libunwind ? sys-libs/libunwind)
# x11-base/xorg-server-21.1.3 (unwind ? sys-libs/libunwind)
# x11-base/xwayland-21.1.4 (unwind ? sys-libs/libunwind)
