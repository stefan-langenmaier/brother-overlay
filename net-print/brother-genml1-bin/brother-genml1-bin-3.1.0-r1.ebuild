# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit rpm

DESCRIPTION="Generic Brother printer driver for DCP-7060D, DCP-7065DN, DCP-8080DN, DCP-L2520DW, DCP-L2540DW, HL-2230, HL-2240, HL-2240D, HL-2270DW, HL-2280DW, HL-5370DW/HL-5370DWT, HL-5440D, HL-5450DN, HL-5470DW, HL-6180DW, HL-L2320D, HL-L2360DW, HL-L2380DW, MFC-7360N, MFC-7460DN, MFC-7860DW, MFC-8480DN, MFC-8510DN, MFC-8710DW, MFC-8890DW, MFC-8910DW, MFC-8950DW, MFC-L2700DW, MFC-L2720DW, MFC-L2740DW"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf101124/brgenml1lpr-3.1.0-1.i386.rpm
	http://download.brother.com/welcome/dlf101126/brgenml1cupswrapper-3.1.0-1.i386.rpm"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="x86"

IUSE=""

RESTRICT="mirror strip"

DEPEND="net-print/cups
	!net-print/brother-mfc7460dn-bin"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

src_prepare() {
	# adapted from the archlinux package
	# https://aur.archlinux.org/packages/brother-brgenml1/
	epatch "${FILESDIR}/brother_lpdwrapper_BrGenML1.patch"
}


src_install() {
	cp -r var "${D}" || die
	cp -r opt "${D}" || die
	cp -r etc "${D}" || die


	mkdir -p ${D}/usr/libexec/cups/filter || die
	( cd ${D}/usr/libexec/cups/filter/ && ln -s ../../../../opt/brother/Printers/BrGenML1/cupswrapper/brother_lpdwrapper_BrGenML1 ) || die

	mkdir -p ${D}/usr/share/cups/model || die
	( cd ${D}/usr/share/cups/model && ln -s ../../../../opt/brother/Printers/BrGenML1/cupswrapper/brother-BrGenML1-cups-en.ppd ) || die
}
