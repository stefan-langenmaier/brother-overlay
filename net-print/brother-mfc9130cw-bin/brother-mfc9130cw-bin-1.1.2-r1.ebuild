# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm multilib

DESCRIPTION="Brother printer driver for MFC-9130CW"

HOMEPAGE="http://support.brother.com"

SRC_URI="https://download.brother.com/welcome/dlf100409/mfc9130cwlpr-1.1.2-1.i386.rpm
	https://download.brother.com/welcome/dlf100411/mfc9130cwcupswrapper-1.1.4-0.i386.rpm"

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

	dosbin "${WORKDIR}/usr/bin/brprintconf_mfc9130cw"

	cp -r usr "${D}" || die
	cp -r opt "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( cd "${D}/usr/libexec/cups/filter/" && ln -s ../../../../opt/brother/Printers/mfc9130cw/lpd/filtermfc9130cw brother_lpdwrapper_mfc9130cw ) || die

	mkdir -p "${D}/usr/share/cups/model" || die
	( cd "${D}/usr/share/cups/model" && ln -s ../../../../opt/brother/Printers/mfc9130cw/cupswrapper/brother_mfc9130cw_printer_en.ppd ) || die
}

pkg_postinst() {
	einfo "If you have the avahi use flag enabled"
	einfo "then you have to edit the file /etc/nsswitch.conf and modify the hosts line"
	einfo "hosts:       files mdns_minimal dns mdns"
	einfo "and you have to add .local to the printer name in cups, like ldp://BRN1234.local/binary_p1"
	einfo "If not using Avahi, you have to hardcode the IP address into cups"
	einfo "Open a web browser and go to http://localhost:631/printers"
	einfo "Click \"Modify Printer\" and set following parameters."
	einfo "- \"LPD/LPR Host or Printer\" or \"AppSocket/HP JetDirect\" for Device"
	einfo "- lpd://(Your printer's IP address)/binary_p1               for Device URI"
	einfo "- Brother                                                   for Make/Manufacturer Selection"
	einfo "- Your printer's name                                       for Model/Driver Selectiion"
}
