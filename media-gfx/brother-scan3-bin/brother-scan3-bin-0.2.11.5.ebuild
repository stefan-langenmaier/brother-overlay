# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

#based on ebuilds from the funtoo and flow overlay

inherit rpm versionator

MY_PV="$(replace_version_separator 3 -)"
MY_PN=brscan3

DESCRIPTION="Brother scanner tool (brscan3)"

HOMEPAGE="http://support.brother.com"

#this version is only for x86_64 available
SRC_URI="amd64? ( http://download.brother.com/welcome/dlf006644/${MY_PN}-${MY_PV}.x86_64.rpm ) "
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="-* amd64"

IUSE=""

RESTRICT="mirror strip"

DEPEND="media-gfx/sane-backends[usb]"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	cp -r usr "${D}" || die

	mkdir -p "${D}/etc/sane.d/dll.d"
	echo "brother3" >"${D}/etc/sane.d/dll.d/brscan3.conf"
}

pkg_postinst() {
	"${ROOT}/usr/local/Brother/sane/setupSaneScan3" -i
	#this is already done with the previous line
	#einfo "In order to use scanner you need to add it first with setupSaneScan3."

	einfo "Example with MFC-9320CW over network:"
	einfo "	/usr/local/Brother/sane/brsaneconfig3 -a name=mfcscan model=MFC-9320CW ip=192.168.250.4"
	einfo "	chmod 644 /usr/local/Brother/sane/brsanenetdevice3.cfg"

	#only for usb access
#	elog "You may need to be in the scanner or plugdev group in order to use the scanner"
}

pkg_prerm() {
	${ROOT}/usr/local/Brother/sane/setupSaneScan3 -e
}
