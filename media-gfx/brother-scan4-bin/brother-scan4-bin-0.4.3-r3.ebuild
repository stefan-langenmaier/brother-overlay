# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

#based on ebuilds from the funtoo and flow overlay

inherit rpm versionator

MY_PR="3"
MY_PN=brscan4

DESCRIPTION="Brother scanner tool (brscan4)"

HOMEPAGE="http://support.brother.com"

SRC_URI="amd64? ( http://download.brother.com/welcome/dlf006648/${MY_PN}-${PV}-${MY_PR}.x86_64.rpm )
	x86? (	http://download.brother.com/welcome/dlf006647/${MY_PN}-${PV}-${MY_PR}.i386.rpm ) "
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~x86"

RESTRICT="mirror strip"

DEPEND="virtual/libusb:0
	media-gfx/sane-backends[usb]"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

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
}
