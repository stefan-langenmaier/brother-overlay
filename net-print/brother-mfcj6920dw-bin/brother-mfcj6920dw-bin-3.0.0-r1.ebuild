# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit rpm multilib

PRINTER_MODEL=${PN#*-}
PRINTER_MODEL=${PRINTER_MODEL%-*}

DESCRIPTION="Brother printer drive for MFC-J6920DW"
HOMEPAGE="https://support.brother.com/g/b/downloadhowto.aspx?c=us&lang=en&prod=mfcj6920dw_us_eu_as"
SRC_URI="
	https://download.brother.com/welcome/dlf100970/${PRINTER_MODEL}cupswrapper-${PV}-1.i386.rpm
	https://download.brother.com/welcome/dlf100968/${PRINTER_MODEL}lpr-${PV}-1.i386.rpm
"

RESTRICT="mirror strip"

LICENSE="brother-eula"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="scanner"

DEPEND=">=net-print/cups-2.2.7"
RDEPEND="
	${DEPEND}
	scanner? ( >=media-gfx/brother-mfcj6920dw-bin-1.0 )
"

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

	exeinto opt/brother/Printers/${PRINTER_MODEL}/cupswrapper
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/lpd/filter${PRINTER_MODEL}
	dosym "${EPREFIX}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/filter${PRINTER_MODEL} "${EPREFIX}"/usr/libexec/cups/filter/brother_lpdwrapper_${PRINTER_MODEL}

	insinto usr/share/ppd/Brother
	doins "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_${PRINTER_MODEL}_printer_en.ppd
}

pkg_postinst() {
	einfo "If your printer ignores your lower paper tray,"
	einfo "use following command to fix it:"
	einfo "brprintconf_mfcj6920dw -pt A4"
}
