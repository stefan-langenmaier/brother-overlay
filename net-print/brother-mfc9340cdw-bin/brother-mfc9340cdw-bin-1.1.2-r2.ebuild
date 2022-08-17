# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm multilib

DESCRIPTION="Brother printer driver for MFC-9340CDW"
HOMEPAGE="http://support.brother.com"
SRC_URI="http://download.brother.com/welcome/dlf007026/mfc9340cdwlpr-1.1.2-1.i386.rpm
http://download.brother.com/welcome/dlf007028/mfc9340cdwcupswrapper-1.1.4-0.i386.rpm"

LICENSE="brother-eula"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

RESTRICT="mirror strip"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	local printer="mfc9340cdw"

	has_multilib_profile && ABI=x86

	insinto opt/brother/Printers/${printer}
	doins -r "${S}"/opt/brother/Printers/${printer}/inf

	exeinto opt/brother/Printers/${printer}/lpd
	doexe "${S}"/opt/brother/Printers/${printer}/lpd/*

	# Printer configuration utility
	dobin "${S}"/usr/bin/brprintconf_${printer}

	# Install wrapping tools for CUPS
	exeinto opt/brother/Printers/${printer}/cupswrapper
	doexe "${S}"/opt/brother/Printers/${printer}/cupswrapper/brcupsconfpt1

	exeinto usr/libexec/cups/filter
	doexe "${FILESDIR}"/cupswrapper-1.1.4/brother_lpdwrapper_${printer}

	insinto usr/share/ppd/Brother
	doins "${S}"/opt/brother/Printers/${printer}/cupswrapper/brother_${printer}_printer_en.ppd
}
