# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rpm

DESCRIPTION="Brother printer driver for MFC-9320CW"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf006460/mfc9320cwlpr-1.1.2-1.i386.rpm
	http://download.brother.com/welcome/dlf006462/mfc9320cwcupswrapper-1.1.2-2.i386.rpm"

LICENSE="brother-eula"

SLOT="0"

KEYWORDS="amd64"

IUSE="+avahi"

RESTRICT="mirror strip"

DEPEND="net-print/cups
	avahi? ( sys-auth/nss-mdns
		net-dns/avahi
		)"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	has_multilib_profile && ABI=x86

	dosbin "${WORKDIR}/usr/bin/brprintconf_mfc9320cw"

	cp -r usr "${D}" || die
	cp -r opt "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( cd "${D}/usr/libexec/cups/filter/" && ln -s ../../../../opt/brother/Printers/mfc9320cw/lpd/filtermfc9320cw brlpdwrappermfc9320cw ) || die

	mkdir -p "${D}/usr/share/cups/model" || die
	( cd "${D}/usr/share/cups/model" && ln -s ../../../../opt/brother/Printers/mfc9320cw/cupswrapper/brother_mfc9320cw_printer_en.ppd ) || die
}

pkg_postinst() {
	einfo "You have to hardcode the ip address in Cups"
	einfo "except if you have the avahi use flag enabled"
	einfo "then you have to edit the file /etc/nsswitch.conf and modify the hosts line"
	einfo "hosts:       files mdns_minimal dns mdns"
	einfo "and you have to add .local to the printer name in cups, like ldp://BRN1234.local/BINARY_P1"
}
