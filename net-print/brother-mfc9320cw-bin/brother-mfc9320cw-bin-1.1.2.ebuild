# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit rpm

DESCRIPTION="Brother printer driver for MFC-9320CW"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf006460/mfc9320cwlpr-1.1.2-1.i386.rpm
	http://download.brother.com/welcome/dlf006462/mfc9320cwcupswrapper-1.1.2-2.i386.rpm"

LICENSE="brother-eula"

SLOT="0"

KEYWORDS="amd64"

IUSE=""

RESTRICT="mirror strip"

DEPEND="net-print/cups"
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


	mkdir -p ${D}/usr/libexec/cups/filter || die
	( cd ${D}/usr/libexec/cups/filter/ && ln -s ../../../../opt/brother/Printers/mfc9320cw/lpd/filtermfc9320cw brlpdwrappermfc9320cw ) || die

	mkdir -p ${D}/usr/share/cups/model || die
	( cd ${D}/usr/share/cups/model && ln -s ../../../../opt/brother/Printers/mfc9320cw/cupswrapper/brother_mfc9320cw_printer_en.ppd ) || die
}
