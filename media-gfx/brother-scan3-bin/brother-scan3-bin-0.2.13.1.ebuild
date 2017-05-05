# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

#based on ebuilds from the funtoo and flow overlay

inherit rpm versionator

MY_PV="$(replace_version_separator 3 -)"
MY_PN=brscan3

DESCRIPTION="Brother scanner driver (brscan3)"

HOMEPAGE="http://support.brother.com"

SRC_URI="amd64? ( http://download.brother.com/welcome/dlf006644/${MY_PN}-${MY_PV}.x86_64.rpm )
	x86? ( http://download.brother.com/welcome/dlf006643/${MY_PN}-${MY_PV}.i386.rpm ) "
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

IUSE=""

RESTRICT="mirror strip"

DEPEND="media-gfx/sane-backends[usb]"
RDEPEND="${DEPEND}
	virtual/libusb:0"

S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	cp -r usr "${D}" || die

	mkdir -p "${D}/etc/sane.d/dll.d" || die
	echo "brother3" >"${D}/etc/sane.d/dll.d/brscan3.conf" || die
}

pkg_postinst() {
	"${ROOT}/usr/local/Brother/sane/setupSaneScan3" -i || die

	einfo "Example with MFC-7440N over network:"
	einfo "	/usr/local/Brother/sane/brsaneconfig3 -a name=MFC-7440N model=MFC-7440N ip=192.168.250.4"
	einfo "	/usr/local/Brother/sane/brsaneconfig3 -a name=MFC-7440N model=MFC-7440N nodename=mfc7440n"
	einfo "	chmod 644 /usr/local/Brother/sane/brsanenetdevice3.cfg"

	#only for usb access
	elog "You may need to be in the scanner or plugdev group in order to use the scanner"
}

pkg_prerm() {
	"${ROOT}/usr/local/Brother/sane/setupSaneScan3" -e || die
}
