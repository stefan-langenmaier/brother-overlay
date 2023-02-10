# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm linux-info

DESCRIPTION="Brother printer driver for DCP-9010CN"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://www.brother.com/pub/bsc/linux/dlf/dcp9010cnlpr-1.1.2-1.i386.rpm
http://www.brother.com/pub/bsc/linux/dlf/dcp9010cncupswrapper-1.1.2-2.i386.rpm"

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
	mkdir -p "${D}"/usr/libexec/cups/filter || die
	mkdir -p "${D}"/usr/share/cups/model/Brother || die
	cp -r opt "${D}" || die
	cp -r usr "${D}" || die

	sed -n 110,260p "${D}"/opt/brother/Printers/dcp9010cn/cupswrapper/cupswrapperdcp9010cn | sed 's/${printer_model}/dcp9010cn/g;s/${device_model}/Printers/g;s/${printer_name}/DCP9010CN/g;s/\\//g' > "${D}"/usr/libexec/cups/filter/brlpdwrapperdcp9010cn || die
	chmod 0755 "${D}"/usr/libexec/cups/filter/brlpdwrapperdcp9010cn || die

	( ln -s "${D}"/opt/brother/Printers/dcp9010cn/cupswrapper/brother_dcp9010cn_printer_en.ppd "${D}"/usr/share/cups/model/Brother/brother_dcp9010cn_printer_en.ppd ) || die
}

pkg_postinst() {
	einfo "Brother DCP-9010CN printer installed"
}
