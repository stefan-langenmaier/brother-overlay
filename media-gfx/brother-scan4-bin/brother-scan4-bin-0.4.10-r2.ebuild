# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# based on ebuilds from funtoo and flow overlay

EAPI=8

inherit rpm udev

BUILD=1
MY_PN=brscan4

DESCRIPTION="Brother scanner tool version 4"
HOMEPAGE="http://support.brother.com/g/s/id/linux/en/index.html"
SRC_URI="amd64? ( http://download.brother.com/welcome/dlf006648/${MY_PN}-${PV}-${BUILD}.x86_64.rpm )
	x86? (	http://download.brother.com/welcome/dlf006647/${MY_PN}-${PV}-${BUILD}.i386.rpm )
	http://download.brother.com/welcome/dlf006653/brother-udev-rule-type1-1.0.2-0.noarch.rpm"
LICENSE="GPL-2 brother-eula no-source-code"
SLOT="0"

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

PATCHES=( "${FILESDIR}/${PN}-fix-udev-rules.patch" )

S="${WORKDIR}"

src_install() {
	local brscan4dir="opt/brother/scanner/brscan4"

	exeinto usr/$(get_libdir)/sane
	doexe usr/$(get_libdir)/sane/libsane-brother4.so.1.0.7
	dosym libsane-brother4.so.1.0.7 /usr/$(get_libdir)/sane/libsane-brother4.so.1
	dosym libsane-brother4.so.1.0.7 /usr/$(get_libdir)/sane/libsane-brother4.so

	udev_newrules opt/brother/scanner/udev-rules/type1/NN-brother-mfp-type1.rules 41-brother-mfp-type1.rules

	cd ${brscan4dir} || die
	insinto ${brscan4dir}
	doins -r Brsane4.ini brsanenetdevice4.cfg models4

	exeinto ${brscan4dir}
	doexe brsaneconfig4
	doexe brscan_gnetconfig
	doexe brscan_cnetconfig

	# Install necessary symlinks (as found in rpm and used by brsaneconfig4)
	dosym ../../${brscan4dir}/brsaneconfig4 /usr/bin/brsaneconfig4
	dodir etc/${brscan4dir}
	for config in Brsane4.ini brsanenetdevice4.cfg models4 ; do
		dosym ../../../../../${brscan4dir}/${config} /etc/${brscan4dir}/${config}
	done

	# Install sane configuration so it does not collide with other packages
	echo "brother4" > brscan4.conf || die
	insinto etc/sane.d/dll.d
	doins brscan4.conf

	echo 'CONFIG_PROTECT="/opt/brother/scanner/brscan4/brsanenetdevice4.cfg"' > "${T}/50brscan4" || die
	doenvd "${T}/50brscan4"
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
