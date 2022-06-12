# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools git-r3

export PKG_COMMIT="5ad84d8"
export BUILDROOT_TAG="2019.02.6"
export SYSLINUX="syslinux-6.03"

KEYWORDS="~amd64"

DESCRIPTION="ChubbyAnt's fork of the Drive-Trust-Alliance sedutil offering stronger security."
HOMEPAGE="https://github.com/ChubbyAnt/sedutil"

LICENSE="GPL-3"
SLOT="0"
IUSE="bios +bundled-syslinux +pba rescue32 +rescue64 +uefi64"
REQUIRED_USE="
	bundled-syslinux? ( pba )
	pba? ( || ( bios uefi64 ) )
	bios? ( rescue32 )
	uefi64? ( rescue64 )
"

if [[ ${PV} == 9999 ]]; then
	GIT_REPOS=( "https://github.com/ChubbyAnt/sedutil" "https://git.buildroot.net/buildroot" )
	EGIT_CLONE_TYPE="single"
else
	GIT_REPOS=( "https://github.com/ChubbyAnt/sedutil" "https://git.buildroot.net/buildroot" )
	EGIT_CLONE_TYPE="single"
	SRC_URI="https://github.com/ChubbyAnt/sedutil/archive/refs/tags/${PV}-${PGK_COMMIT}.tar.gz"
fi

DEPEND="
	>=app-arch/cpio-2.12-r1
	>=app-arch/tar-1.34
	>=app-arch/unzip-6.0_p26
	>=app-arch/xz-utils-5.2.5
	>=app-arch/zip-3.0-r4
	>=dev-lang/nasm-2.15.05
	>=dev-libs/libbsd-0.10.0
	>=net-misc/curl-7.77.0-r1
	>=net-misc/rsync-3.2.3-r4
	>=sys-apps/debianutils-4.11.2[installkernel]
	>=sys-apps/util-linux-2.36.2[logger,ncurses,nls,tty-helpers]
	>=sys-devel/bc-1.07.1-r3
	>=sys-libs/ncurses-6.2-r1
	>=sys-libs/zlib-1.2.11-r4
	!bundled-syslinux? ( >=sys-boot/syslinux-6.04_pre1-r2 )
"
RDEPEND="${DEPEND} !sys-block/sedutil"
BDEPEND=""

setup_pba() {
	cd "${WORKDIR}/${P}/images/scratch/buildroot"

	git checkout -b PBABUILD ${BUILDROOT_TAG}
	git reset --hard
	git clean -df

	# Add output artifact directory
	#mkdir dl

	# Add out of tree build directories and files - 64-bit
	mkdir 64bit
	cp ../../buildroot/64bit/.config 64bit/
	cp ../../buildroot/64bit/* 64bit/
	cp -r ../../buildroot/64bit/overlay 64bit/

	# Add out of tree build directories and files - 32-bit
	mkdir 32bit
	cp ../../buildroot/32bit/.config 32bit/
	cp ../../buildroot/32bit/* 32bit/
	cp -r ../../buildroot/32bit/. 32bit/

	# Add the current buildroot packages
	sed -i '/sedutil/d' package/Config.in
	sed -i '/menu "System tools"/a \\tsource "package/sedutil/Config.in"' package/Config.in
	cp -r ../../buildroot/packages/sedutil/ package/

	# Add boot image directories
	cd "${WORKDIR}/${P}/images"
	mkdir -p BIOS32/image UEFI64/image
	mv "${WORKDIR}/sedutil2_bios_boot.img" "${WORKDIR}/${P}/images/BIOS32/"
	mv "${WORKDIR}/sedutil2_uefi64_boot.img" "${WORKDIR}/${P}/images/UEFI64/"

	# Add rescue image directories
	cd "${WORKDIR}/${P}/images"
	mkdir scratch/rescuefs
	mkdir -p RESCUE32 RESCUE64
	mv "${WORKDIR}/sedutil2_rescue32_boot.img" "${WORKDIR}/${P}/images/RESCUE32/"
	mv "${WORKDIR}/sedutil2_rescue64_boot.img" "${WORKDIR}/${P}/images/RESCUE64/"
}

build_img() {
	local BUILDTYPE=""
	local VERSION=`git describe --dirty` || local VERSION="tarball"
	local BUILDIMG=""
	local ROOTDIR=""
	use bundled-syslinux && SYSLINUX="syslinux-6.03" || SYSLINUX="syslinux"
	local SYSDIR=""
	local SYS_FILES=""
	local BROOT_FILES=(
		'images/bzImage'
		'images/rootfs.cpio.xz'
		'target/sbin/linuxpba'
		'target/sbin/sedutil-cli'
	)

	if [ "x$*" = "xbios" ] ; then
		BUILDTYPE=BIOS32
		BUILDIMG=${BUILDTYPE}-${VERSION}.img
		ROOTDIR="32bit"
		SYSDIR="bios"
		SYS_FILES=( "mbr/mbr.bin" "extlinux/extlinux" )

		# Check BIOS syslinux files exist
		for f in ${SYS_FILES[@]}; do
			[ -f scratch/${SYSLINUX}/${SYSDIR}/${f} ] || { die "Missing file: ${f}!"; }

			if [ "X${f}" = "Xextlinux/extlinux" ] ; then
				[ -x ${f} ] || { die "Not executable: ${f}!"; }
			fi
		done

		# Check BIOS buildroot files exist
		for f in ${BROOT_FILES[@]}; do
			[ -f scratch/buildroot/${ROOTDIR}/${f} ] || { die "Missing file: ${f}!"; }

			if [ "X${f}" = "Xsbin/linuxpba" || "X${f}" = "Xsbin/sedutil-cli" ] ; then
				[ -x ${f} ] || { die "Not executable: ${f}!"; }
			fi
		done

		# Check that the syslinux config exists
		[ -f buildroot/syslinux.cfg ] || { die "Missing file: ${f}!"; }

		# Setup the BIOS boot image
		cd ${BUILDTYPE} && mv sedutil2-bios-boot.img ${BUILDIMG}.img
		dd if=../scratch/${SYSLINUX}/${SYSDIR}/${SYS_FILES[0]} of=${BUILDIMG} count=1 conv=notrunc bs=512
		local LOOPDEV=$(losetup --show -f -o 1048576 ${BUILDIMG})
		mkfs.ext4 $LOOPDEV -L ${BUILDTYPE}
		mount $LOOPDEV image
		chmod 777 image
		mkdir -p image/boot/extlinux

		# Install BIOS boot image files
		../scratch/${SYSLINUX}/${SYSDIR}/${SYS_FILES[1]} --install image/boot/extlinux
		cp ../scratch/buildroot/${ROOTDIR}/${BROOT_FILES[0]} image/boot/extlinux/
		cp ../scratch/buildroot/${ROOTDIR}/${BROOT_FILES[1]} image/boot/extlinux/
		cp ../buildroot/syslinux.cfg image/boot/extlinux/extlinux.conf

		# Zip-up the BIOS boot image
		umount image
		losetup -d $LOOPDEV
		gzip ${BUILDIMG}
	fi

	if [ "x$*" = "xuefi64" ] ; then
		BUILDTYPE=UEFI64
		BUILDIMG=${BUILDTYPE}-${VERSION}.img
		ROOTDIR="64bit"
		SYSDIR="efi64"
		SYS_FILES=( "efi/syslinux.efi" "com32/elflink/ldlinux/ldlinux.e64" )

		# Check UEFI64 syslinux files exist
		for f in ${SYS_FILES[@]}; do
			[ -f scratch/${SYSLINUX}/${SYSDIR}/${f} ] || { die "Missing file: ${f}!"; }
		done

		# Check UEFI64 buildroot files exist
		for f in ${BROOT_FILES[@]}; do
			[ -f scratch/buildroot/${ROOTDIR}/${f} ] || { die "Missing file: ${f}!"; }
		done

		# Check that the syslinux config exists
		[ -f buildroot/syslinux.cfg ] || { die "Missing file: ${f}!"; }

		# Setup the UEFI64 boot image
		cd ${BUILDTYPE} && mv sedutil2-uefi64-boot.img ${BUILDIMG}.img
		local LOOPDEV=$(losetup --show -f -o 1048576 ${BUILDIMG})
		mkfs.vfat $LOOPDEV -n ${BUILDTYPE}
		mount $LOOPDEV image
		chmod 777 image
		mkdir -p image/EFI/boot

		# Install UEFI64 boot image files
		cp ../scratch/${SYSLINUX}/${SYSDIR}/${SYS_FILES[0]} image/EFI/boot/bootx64.efi
		cp ../scratch/buildroot/${ROOTDIR}/${SYS_FILES[1]} image/EFI/boot/
		cp ../scratch/buildroot/${ROOTDIR}/${BROOT_FILES[0]} image/EFI/boot/
		cp ../scratch/buildroot/${ROOTDIR}/${BROOT_FILES[1]} image/EFI/boot/
		cp ../buildroot/syslinux.cfg image/EFI/boot/

		# Zip-up the UEFI64 boot image
		umount image
		losetup -d $LOOPDEV
		gzip ${BUILDIMG}
	fi

	if [ "x$*" = "xrescue32" ] ; then
		BUILDTYPE=RESCUE32
		BUILDIMG=${BUILDTYPE}-${VERSION}.img
		ROOTDIR="32bit"
		SYSDIR="bios"
		SYS_FILES=( "mbr/mbr.bin" "extlinux/extlinux" )

		[ -f BIOS32/BIOS32-*.img.gz ] || { die "Missing file: ${f}!"; }

		# Prepare the RESCUE32 root fs
		rm -f scratch/buildroot/${ROOTDIR}/images/rescuefs.cpio.xz
		cd "${WORKDIR}/${P}/images/scratch/rescuefs"
		xz --decompress --stdout ../buildroot/${ROOTDIR}/images/rootfs.cpio.xz | cpio -i -H newc -d
		cp "${FILESDIR}/rescue-etc-issue" etc/issue
		rm etc/init.d/S99*
		mkdir -p usr/sedutil
		cp ../../UEFI64/UEFI64-*.img.gz usr/sedutil/
		cp ../../BIOS32/BIOS32-*.img.gz usr/sedutil/
		find . | cpio -o -H newc | xz -9 -c crc32 -c > ../buildroot/${ROOTDIR}/images/rescuefs.cpio.xz
		cd ${WORKDIR}/${P}/images
		rm -rf scratch/rescuefs

		# Setup the RESCUE32 boot image
		cd ${BUILDTYPE} && mv sedutil2_rescue32_boot.img ${BUILDIMG}
		dd if=../scratch/${SYSLINUX}/${SYSDIR}/${SYS_FILES[0]} of=${BUILDIMG} count=1 conv=notrunc bs=512
		local LOOPDEV=$(losetup --show -f -o 1048576 ${BUILDIMG})
		mkfs.ext4 $LOOPDEV -L ${BUILDTYPE}
		mkdir image
		mount $LOOPDEV image
		chmod 777 image

		# Install RESCUE32 boot image files
		mkdir -p image/boot/extlinux
		../scratch/${SYSLINUX}/${SYSDIR}/${SYS_FILES[1]} --install image/boot/extlinux
		cp ../scratch/buildroot/${ROOTDIR}/${BROOT_FILES[0]} image/boot/extlinux/
		cp ../scratch/buildroot/${ROOTDIR}/images/rescuefs.cpio.xz image/boot/extlinux/rootfs.cpio.xz
		cp ../buildroot/syslinux.cfg image/boot/extlinux/extlinux.conf

		# Zip-up the RESCUE32 boot image
		umount image
		losetup -d $LOOPDEV
		gzip ${BUILDIMG}
	fi

	if [ "x$*" = "xrescue64" ] ; then
		BUILDTYPE=RESCUE64
		BUILDIMG=${BUILDTYPE}-${VERSION}.img
		ROOTDIR="64bit"
		SYSDIR="efi64"
		SYS_FILES=( "efi/syslinux.efi" "com32/elflink/ldlinux/ldlinux.e64" )

		[ -f UEFI64/UEFI64-*.img.gz ] || { die "Missing file: ${f}!"; }

		# Prepare the RESCUE64 root fs
		rm -f scratch/buildroot/${ROOTDIR}/images/rescuefs.cpio.xz
		cd "${WORKDIR}/${P}/images/scratch/rescuefs"
		xz --decompress --stdout ../buildroot/${ROOTDIR}/images/rootfs.cpio.xz | cpio -i -H newc -d
		cp "${FILESDIR}/rescue-etc-issue" etc/issue
		rm etc/init.d/S99*
		mkdir -p usr/sedutil
		cp ../../UEFI64/UEFI64-*.img.gz usr/sedutil/
		cp ../../BIOS32/BIOS32-*.img.gz usr/sedutil/
		find . | cpio -o -H newc | xz -9 -c crc32 -c > ../buildroot/${ROOTDIR}/images/rescuefs.cpio.xz
		cd ${WORKDIR}/${P}/images
		rm -rf scratch/rescuefs

		# Setup the RESCUE64 boot image
		cd ${BUILDTYPE} && mv sedutil2_rescue32_boot.img ${BUILDIMG}
		dd if=../scratch/${SYSLINUX}/${SYSDIR}/${SYS_FILES[0]} of=${BUILDIMG} count=1 conv=notrunc bs=512
		local LOOPDEV=$(losetup --show -f -o 1048576 ${BUILDIMG})
		mkfs.vfat $LOOPDEV -L ${BUILDTYPE}
		mkdir image
		mount $LOOPDEV image
		chmod 777 image

		# Install RESCUE64 boot image files
		mkdir -p image/EFI/boot
		cp ../scratch/${SYSLINUX}/${SYSDIR}/${SYS_FILES[0]} image/EFI/boot/bootx64.efi
		cp ../scratch/buildroot/${ROOTDIR}/${SYS_FILES[1]} image/EFI/boot/
		cp ../scratch/buildroot/${ROOTDIR}/${BROOT_FILES[0]} image/EFI/boot/
		cp ../scratch/buildroot/${ROOTDIR}/images/rescuefs.cpio.xz image/EFI/boot/rootfs.cpio.xz
		cp ../buildroot/syslinux.cfg image/EFI/boot/

		# Zip-up the RESCUE64 boot image
		umount image
		losetup -d $LOOPDEV
		gzip ${BUILDIMG}
	fi
}

# Couldn't get this to work with mixed fetch/no_fetch src_uri entries.
# Ended up just packing all images with the ebuild inf ${FILESDIR} since
# they are very small.
#pkg_nofetch() {
#	einfo ""
#	einfo "  This package requires up to four blank image files in order to build"
#	einfo "  valid PBA boot and rescue images depending upon USE-flag selection."
#	einfo "  You can create the requisite image(s) using the following procedure."
#	einfo "  Once created, move them to your Portage \$DISTDIR directory."
#	einfo ""
#	einfo "  BIOS:"
#	einfo "        mkdir BIOS32 && cd BIOS32"
#	einfo "        BUILDIMG=\"sedutil2_bios_boot.img\""
#	einfo "        dd if=/dev/zero of=\${BUILDIMG} bs=1M count=32"
#	einfo "        (echo o;echo n;echo p;echo 1;echo \"\";echo \"\";echo a;echo w) | fdisk \${BUILDIMG}"
#	einfo "        gzip \${BUILDIMG}"
#	einfo "        chown portage:portage \${BUILDIMG}"
#	einfo ""
#	einfo "  RESCUE32:"
#	einfo "        mkdir RESCUE32 && cd RESCUE32"
#	einfo "        BUILDIMG=\"sedutil2_rescue32_boot.img\""
#	einfo "        dd if=/dev/zero of=\${BUILDIMG} bs=1M count=75"
#	einfo "        (echo o;echo n;echo p;echo 1;echo \"\";echo \"\";echo a;echo w) | fdisk -C 100 \${BUILDIMG}"
#	einfo "        gzip \${BUILDIMG}"
#	einfo "        chown portage:portage \${BUILDIMG}"
#	einfo ""
#	einfo "  UEFI64:"
#	einfo "        mkdir UEFI64 && cd UEFI64"
#	einfo "        BUILDIMG=\"sedutil2_uefi64_boot.img\""
#	einfo "        dd if=/dev/zero of=\${BUILDIMG} bs=1M count=32"
#	einfo "        (echo n;echo \"\";echo \"\";echo \"\";echo \"ef00\";echo w;echo Y) | gdisk \${BUILDIMG}"
#	einfo "        gzip \${BUILDIMG}"
#	einfo "        chown portage:portage \${BUILDIMG}"
#	einfo ""
#	einfo "  RESCUE64:"
#	einfo "        mkdir RESCUE64 && cd RESCUE64"
#	einfo "        BUILDIMG=\"sedutil2_rescue64_boot.img\""
#	einfo "        dd if=/dev/zero of=\${BUILDIMG} bs=1M count=75"
#	einfo "        (echo n;echo \"\";echo \"\";echo \"\";echo \"ef00\";echo w;echo Y) | gdisk \${BUILDIMG}"
#	einfo "        gzip \${BUILDIMG}"
#	einfo "        chown portage:portage \${BUILDIMG}"
#	einfo ""
#}

src_unpack() {
	default

	# Fetch pkg & buildroot sources
	if [ "X${PV}" = "X9999" ] ; then
		einfo "Fetching package source from ${GIT_REPOS[0]}..."
		git-r3_fetch ${GIT_REPOS[0]}
		git-r3_checkout ${GIT_REPOS[0]}
	fi

	# Fetch pkg and/or syslinux sources
	einfo "Fetching package dependencies from ${GIT_REPOS[1]}..."
	git-r3_fetch ${GIT_REPOS[1]} "refs/tags/${BUILDROOT_TAG}"
	EGIT_CHECKOUT_DIR="${WORKDIR}/buildroot"
	git-r3_checkout ${GIT_REPOS[1]}
	unset EGIT_CHECKOUT_DIR

	# Unpack bundled dependencies
	unpack "${FILESDIR}/sedutil2_bios_boot.img.gz"
	unpack "${FILESDIR}/sedutil2_uefi64_boot.img.gz"
	unpack "${FILESDIR}/sedutil2_rescue32_boot.img.gz"
	unpack "${FILESDIR}/sedutil2_rescue64_boot.img.gz"
	unpack "${FILESDIR}/syslinux-6.03.tar.xz"
}

src_prepare() {
	default
	eautoreconf
}

src_compile() {
	emake all

	if use pba ; then
		rm -rfd ${WORKDIR}/${P}/images/scratch
		mkdir ${WORKDIR}/${P}/images/scratch
		use bundled-syslinux && mv "${WORKDIR}/syslinux-6.03" "${WORKDIR}/${P}/images/scratch/syslinux-6.03"

		rm -rfd ${WORKDIR}/${P}/images/scratch/buildroot
		mv "${WORKDIR}/buildroot" "${WORKDIR}/${P}/images/scratch/buildroot"
		setup_pba

		# Build pbaroot
		cd "${WORKDIR}/${P}"
		#eautoreconf
		#econf
		autoreconf
		./configure
		make dist

		mkdir images/scratch/buildroot/dl
		cp sedutil-*.tar.gz images/scratch/buildroot/dl/
		make distclean

		cd images/scratch/buildroot/dl
		tar xvfz sedutil-*.tar.gz
		cd ..

		if use uefi64 ; then
			einfo "Building the 64-bit PBA Linux system..."
			make -j1 O=64bit || die

			einfo "Creating the UEFI64 boot image..."
			cd ../..
			build_img uefi64

			einfo "Creating the RESCUE64 boot image..."
			build_img rescue64
		fi

		if use bios ; then
			einfo "Building the 32-bit PBA Linux system..."
			make -j1 O=32bit || die

			einfo "Creating the BIOS boot image..."
			cd ../..
			build_img bios

			einfo "Creating the RESCUE32 boot image..."
			build_img rescue32
		fi
	fi
}
