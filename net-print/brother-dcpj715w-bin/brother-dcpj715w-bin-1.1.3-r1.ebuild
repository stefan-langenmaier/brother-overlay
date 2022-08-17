# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm linux-info

DESCRIPTION="Brother printer driver for DCP-9022CDW"

HOMEPAGE="http://support.brother.com"

SRC_URI="https://download.brother.com/welcome/dlf005606/dcpj715wlpr-1.1.3-1.i386.rpm
https://download.brother.com/welcome/dlf005608/dcpj715wcupswrapper-1.1.3-1.i386.rpm"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~x86"

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
	mkdir -p "${D}"usr/libexec/cups/filter || die
	mkdir -p "${D}"usr/share/cups/model/Brother || die
	cp -r opt "${D}" || die
	cp -r usr "${D}" || die

	( ln -s "${D}"opt/brother/Printers/dcpj715w/cupswrapper/brother_dcpj715w_printer_en.ppd "${D}"usr/share/cups/model/Brother/brother_dcpj715w_printer_en.ppd ) || die
}
