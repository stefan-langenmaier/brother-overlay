# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit rpm multilib

PRINTER_MODEL=${PN#*-}
PRINTER_MODEL=${PRINTER_MODEL%-*}

DESCRIPTION="Brother printer driver for ${PRINTER_MODEL}"
HOMEPAGE="http://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=${PRINTER_MODEL}_all"
SRC_URI="https://download.brother.com/welcome/dlf103955/${PRINTER_MODEL}pdrv-1.0.2-0.i386.rpm"
RESTRICT="mirror strip"

LICENSE="brother-eula"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

DEPEND=">=net-print/cups-2.2.7"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	has_multilib_profile && ABI=x86

	insinto opt/brother/Printers/${PRINTER_MODEL}
	doins -r "${S}"/opt/brother/Printers/${PRINTER_MODEL}/inf

	exeinto opt/brother/Printers/${PRINTER_MODEL}/lpd
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/lpd/*

	# Printer configuration utility
	dobin "${S}"/usr/bin/brprintconf_${PRINTER_MODEL}

	# Install wrapping tools for CUPS
	exeinto opt/brother/Printers/${PRINTER_MODEL}/cupswrapper
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/cupswrapper${PRINTER_MODEL}

	# You have to install the cupswrapper where it wants to be and then symbolically link to it; otherwise the $basedir that is assumed in the script generates confused paths
	exeinto opt/brother/Printers/${PRINTER_MODEL}/cupswrapper
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_lpdwrapper_${PRINTER_MODEL}
	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( ln -s "${D}opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_lpdwrapper_${PRINTER_MODEL}" "${D}/usr/libexec/cups/filter/brother_lpdwrapper_${PRINTER_MODEL}" ) || die

	insinto usr/share/ppd/Brother
	doins "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_${PRINTER_MODEL}_printer_en.ppd
}
