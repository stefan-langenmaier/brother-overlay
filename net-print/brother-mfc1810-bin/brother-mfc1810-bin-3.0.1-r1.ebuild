# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm linux-info
MY_PN="mfc1810"
MY_PV="${PV}-1"

DESCRIPTION="Brother printer driver for MFC-1810"
HOMEPAGE="http://support.brother.com"
SRC_URI="https://download.brother.com/welcome/dlf100413/${MY_PN}lpr-${MY_PV}.i386.rpm
	https://download.brother.com/welcome/dlf100415/${MY_PN}cupswrapper-${MY_PV}.i386.rpm
"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

RESTRICT="mirror strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

S=${WORKDIR}

pkg_setup() {
	CONFIG_CHECK=""
	if use amd64; then
		CONFIG_CHECK="${CONFIG_CHECK} ~IA32_EMULATION"
	fi

	linux-info_pkg_setup
}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	MODEL=MFC1810

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	mkdir -p "${D}/usr/share/cups/model/Brother" || die

	cp -r opt "${D}" || die

	( ln -s "${D}/opt/brother/Printers/${MODEL}/cupswrapper/brother_lpdwrapper_${MODEL}" "${D}/usr/libexec/cups/filter/brother_lpdwrapper_${MODEL}" ) || die

	( ln -s "${D}/opt/brother/Printers/${MODEL}/cupswrapper/brother-${MODEL}-cups-en.ppd" "${D}/usr/share/cups/model/Brother/brother_${MODEL}_printer_en.ppd" ) || die
}