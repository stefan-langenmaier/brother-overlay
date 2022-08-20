# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit rpm multilib

PRINTER_MODEL=${PN#*-}
PRINTER_MODEL=${PRINTER_MODEL%-*}

DESCRIPTION="Brother printer drive for ${PRINTER_MODEL}"
HOMEPAGE="https://support.brother.com/g/b/downloadhowto.aspx?c=us&lang=en&prod=${PRINTER_MODEL}_us_eu_as"
SRC_URI="
	https://download.brother.com/welcome/dlf102097/${PRINTER_MODEL}cupswrapper-1.0.0-0.i386.rpm
	https://download.brother.com/welcome/dlf102096/${PRINTER_MODEL}lpr-1.0.0-0.i386.rpm
"

RESTRICT="mirror strip"

LICENSE="brother-eula"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="scanner"

DEPEND=">=net-print/cups-2.2.7"
RDEPEND="
	${DEPEND}
	scanner? ( >=media-gfx/brother-mfcj485dw-bin-1.0 )
"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_prepare() {
	eapply_user

	local BASE_PATH="opt/brother/Printers/${PRINTER_MODEL}"
	local TAG="\!ENDOFWFILTER\!"
	sed -ne "/${TAG}/,/${TAG}/!d" -e "/${TAG}/d; p" < ${BASE_PATH}/cupswrapper/cupswrapper${PRINTER_MODEL} > ${BASE_PATH}/brother_lpdwrapper_${PRINTER_MODEL} || die

	local PRINTER_NAME="${PRINTER_MODEL^^}"
	sed -i -e "s|\${printer_model}|${PRINTER_MODEL}|g;s|\${device_model}|Printers|g;s|\${printer_name}|${PRINTER_NAME}|g;s|exit \$errorcode|exit|" \
		-e 's|\\\([\$\`]\)|\1|g' ${BASE_PATH}/brother_lpdwrapper_${PRINTER_MODEL} || die
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

	exeinto usr/libexec/cups/filter
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/brother_lpdwrapper_${PRINTER_MODEL}

	exeinto opt/brother/Printers/${PRINTER_MODEL}/cupswrapper
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brcupsconfpt1

	insinto usr/share/ppd/Brother
	doins "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_${PRINTER_MODEL}_printer_en.ppd
}
