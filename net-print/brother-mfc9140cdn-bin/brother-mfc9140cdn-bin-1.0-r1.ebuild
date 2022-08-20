# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm linux-info multilib

DESCRIPTION="Brother printer driver for MFC-9140CDN"

HOMEPAGE="http://support.brother.com"

SRC_URI="https://download.brother.com/welcome/dlf100404/mfc9140cdnlpr-1.1.2-1.i386.rpm
https://download.brother.com/welcome/dlf100406/mfc9140cdncupswrapper-1.1.4-0.i386.rpm"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

IUSE=""

RESTRICT="mirror strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	has_multilib_profile && ABI=x86
	MODEL="mfc9140cdn"

	dosbin "${WORKDIR}/usr/bin/brprintconf_${MODEL}"

	cp -r usr "${D}" || die
	cp -r opt "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( cd "${D}/usr/libexec/cups/filter/" && ln -s ../../../../opt/brother/Printers/${MODEL}/lpd/filter${MODEL} brother_lpdwrapper_${MODEL} ) || die

	mkdir -p "${D}/usr/share/cups/model" || die
	( cd "${D}/usr/share/cups/model" && ln -s ../../../../opt/brother/Printers/${MODEL}/cupswrapper/brother_${MODEL}_printer_en.ppd ) || die
}
