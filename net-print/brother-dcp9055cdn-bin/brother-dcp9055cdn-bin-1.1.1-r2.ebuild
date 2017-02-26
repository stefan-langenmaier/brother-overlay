# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils rpm linux-info

DESCRIPTION="Brother printer driver for DCP-9055CDN"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://www.brother.com/pub/bsc/linux/dlf/dcp9055cdnlpr-1.1.1-5.i386.rpm
	http://www.brother.com/pub/bsc/linux/dlf/dcp9055cdncupswrapper-1.1.1-5.i386.rpm"

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
	MODEL="dcp9055cdn"
	mkdir -p "${D}"usr/libexec/cups/filter || die
	mkdir -p "${D}"usr/share/cups/model/Brother || die
	cp -r usr "${D}" || die

	sed -n 94,232p "${D}usr/local/Brother/Printer/${MODEL}/cupswrapper/cupswrapper${MODEL}" | sed 's/${printer_model}/dcp9055cdn/g;s/${device_model}/Printers/g;s/${printer_name}/DCP9055CDN/g;s/\\//g' > "${D}usr"/libexec/cups/filter/brlpdwrapperdcp9055cdn || die
	chmod 0755 "${D}"usr/libexec/cups/filter/brlpdwrapperdcp9055cdn || die

	( ln -s "${D}"usr/local/Brother/Printer/${MODEL}/cupswrapper/${MODEL}.ppd "${D}"usr/share/cups/model/Brother/brother_${MODEL}_printer_en.ppd ) || die
}
