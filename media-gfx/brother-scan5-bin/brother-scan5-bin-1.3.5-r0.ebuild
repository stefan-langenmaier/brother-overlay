# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# based on ebuilds from funtoo and flow overlay

EAPI=8

inherit rpm udev

BUILD=1
MY_PN=brscan5

DESCRIPTION="Brother scanner tool version 5"
HOMEPAGE="http://support.brother.com/g/s/id/linux/en/index.html"
SRC_URI="amd64? ( https://d.brother-movie.com/driver/4025/${MY_PN}-${PV}-0.x86_64.rpm )
	x86? (	https://d.brother-movie.com/driver/4023/${MY_PN}-${PV}-0.i386.rpm )"
	# http://download.brother.com/welcome/dlf006653/brother-udev-rule-type1-1.0.2-0.noarch.rpm"
LICENSE="GPL-2 brother-eula no-source-code"
SLOT="0"
# https://d.brother-movie.com/driver/4025/brscan5-1.3.5-0.x86_64.rpm

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror strip"
IUSE="usb avahi"

RDEPEND="
	net-libs/libnsl
	media-gfx/sane-backends[usb?]
	virtual/libusb:0

	avahi? ( net-dns/avahi
		sys-auth/nss-mdns )
"
DEPEND=""

# PATCHES=( "${FILESDIR}/${PN}-fix-udev-rules.patch" )

S="${WORKDIR}"

src_install() {
	local brscan5dir="opt/brother/scanner/brscan5"

	exeinto usr/$(get_libdir)/sane
	# doexe usr/$(get_libdir)/sane/libsane-brother5.so.1.0.7
	doexe ${brscan5dir}/libsane-brother5.so.1.0.7

	dosym libsane-brother5.so.1.0.7 /usr/$(get_libdir)/sane/libsane-brother5.so.1.0
	dosym libsane-brother5.so.1.0.7 /usr/$(get_libdir)/sane/libsane-brother5.so.1

	exeinto usr/$(get_libdir)
	doexe ${brscan5dir}/libLxBsDeviceAccs.so.1.0.0
	doexe ${brscan5dir}/libLxBsScanCoreApi.so.3.2.0
	doexe ${brscan5dir}/libLxBsNetDevAccs.so.1.0.0
	doexe ${brscan5dir}/libLxBsUsbDevAccs.so.1.0.0

	dosym libLxBsDeviceAccs.so.1.0.0 /usr/$(get_libdir)/libLxBsDeviceAccs.so.1.0
	dosym libLxBsDeviceAccs.so.1.0.0 /usr/$(get_libdir)/libLxBsDeviceAccs.so.1
	dosym libLxBsScanCoreApi.so.3.2.0 /usr/$(get_libdir)/libLxBsScanCoreApi.so.3.2
	dosym libLxBsScanCoreApi.so.3.2.0 /usr/$(get_libdir)/libLxBsScanCoreApi.so.3
	dosym libLxBsNetDevAccs.so.1.0.0 /usr/$(get_libdir)/libLxBsNetDevAccs.so.1.0
	dosym libLxBsNetDevAccs.so.1.0.0 /usr/$(get_libdir)/libLxBsNetDevAccs.so.1
	dosym libLxBsUsbDevAccs.so.1.0.0 /usr/$(get_libdir)/libLxBsUsbDevAccs.so.1.0
	dosym libLxBsUsbDevAccs.so.1.0.0 /usr/$(get_libdir)/libLxBsUsbDevAccs.so.1

	udev_newrules opt/brother/scanner/brscan5/udev-rules/NN-brother-mfp-brscan5-1.0.2-2.rules 60-brother-mfp-brscan5-1.0.2-2.rules
	# udev_newrules opt/brother/scanner/udev-rules/type1/NN-brother-mfp-type1.rules 41-brother-mfp-type1.rules

	cd ${brscan5dir} || die
	insinto ${brscan5dir}
	doins -r brscan5.ini brsanenetdevice.cfg models
	# libLxBsDeviceAccs.so.1.0.0 libLxBsScanCoreApi.so.3.2.0 libLxBsNetDevAccs.so.1.0.0 libLxBsUsbDevAccs.so.1.0.0 libsane-brother5.so.1.0.7

	exeinto ${brscan5dir}
	doexe brsaneconfig5
	doexe brscan_gnetconfig
	doexe brscan_cnetconfig

	# Install necessary symlinks (as found in rpm and used by brsaneconfig4)
	dosym ../../${brscan5dir}/brsaneconfig5 /usr/bin/brsaneconfig5
	dodir etc/${brscan5dir}
	for config in brscan5.ini brsanenetdevice.cfg models ; do
		dosym ../../../../../${brscan5dir}/${config} /etc/${brscan5dir}/${config}
	done

	# Install sane configuration so it does not collide with other packages
	echo "brother5" > brscan5.conf || die
	insinto etc/sane.d/dll.d
	doins brscan5.conf

	echo 'CONFIG_PROTECT="/opt/brother/scanner/brscan5/brsanenetdevice.cfg"' > "${T}/50brscan5" || die
	doenvd "${T}/50brscan5"
}

pkg_postinst() {
	if ! has_version sys-auth/consolekit[acl] && \
		! has_version sys-auth/elogind[acl] && \
		! has_version sys-apps/systemd[acl]
	then
		elog "You may need to be in the scanner or plugdev group in order to use the scanner"
	fi

	elog "To add a network scanner to sane, run:"
	elog "brsaneconfig4 -a name=(name your device) model=(model name) ip=xx.xx.xx.xx"
	elog "or simply run brsaneconfig4 for more options"
}
