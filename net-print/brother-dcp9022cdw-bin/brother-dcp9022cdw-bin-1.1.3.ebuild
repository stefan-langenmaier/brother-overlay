# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils rpm linux-info

DESCRIPTION="Brother printer driver for DCP-9022CDW"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf101614/dcp9022cdwlpr-1.1.3-0.i386.rpm
http://download.brother.com/welcome/dlf101615/dcp9022cdwcupswrapper-1.1.4-0.i386.rpm"

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

src_prepare() {
	return
}

src_install() {
	mkdir -p "${D}"usr/libexec/cups/filter || die
	mkdir -p "${D}"usr/share/cups/model/Brother || die
	cp -r opt "${D}" || die
	cp -r usr "${D}" || die

	sed -n 110,260p "${D}"opt/brother/Printers/dcp9022cdw/cupswrapper/cupswrapperdcp9022cdw | sed 's/${printer_model}/dcp9022cdw/g;s/${device_model}/Printers/g;s/${printer_name}/DCP9022CDW/g;s/\\//g' > "${D}usr"/libexec/cups/filter/brother_lpdwrapper_dcp9022cdw || die
	chmod 0755 "${D}"usr/libexec/cups/filter/brother_lpdwrapper_dcp9022cdw || die

	( ln -s "${D}"opt/brother/Printers/dcp9022cdw/cupswrapper/brother_dcp9022cdw_printer_en.ppd "${D}"usr/share/cups/model/Brother/brother_dcp9022cdw_printer_en.ppd ) || die
}

pkg_postinst() {
	einfo "Brother DCP-9022CDW printer installed"
}
