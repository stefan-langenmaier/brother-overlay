# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# based on ebuilds from funtoo and flow overlay

EAPI="6"

inherit rpm

MY_PR=${PR/r/}
MY_PN=brscan4

DESCRIPTION="Brother scanner tool version 4"
HOMEPAGE="http://support.brother.com/g/s/id/linux/en/index.html"
SRC_URI="amd64? ( http://download.brother.com/welcome/dlf006648/${MY_PN}-${PV}-${MY_PR}.x86_64.rpm )
	x86? (	http://download.brother.com/welcome/dlf006647/${MY_PN}-${PV}-${MY_PR}.i386.rpm )"
LICENSE="GPL-2 brother-eula no-source-code"
SLOT="0"

KEYWORDS="amd64 x86"
RESTRICT="mirror strip"
IUSE="usb"

DEPEND="virtual/libusb:0
	media-gfx/sane-backends"
RDEPEND="${DEPEND}
	usb? ( media-gfx/sane-backends[usb] )"

S=${WORKDIR}

src_install() {
	cp -r usr "${D}" || die
	cp -r etc "${D}" || die
	cp -r opt "${D}" || die

	# so no files from the sane package are touched
	mkdir -p "${D}/etc/sane.d/dll.d" || die
	echo "brother4" >"${D}/etc/sane.d/dll.d/brscan4.conf" || die
}

pkg_postinst() {
	elog "You may need to be in the scanner or plugdev group in order to use the scanner"
	elog "To add a network scanner to sane, run:"
	elog "brsaneconfig4 -a name=(name your device) model=(model name) ip=xx.xx.xx.xx"
	elog "or simply run brsaneconfig4 for more options"
}
