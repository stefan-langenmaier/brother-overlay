# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit rpm

DESCRIPTION="Brother printer driver for HL-4150CDN"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf005939/hl4150cdnlpr-1.1.1-5.i386.rpm
	http://download.brother.com/welcome/dlf005941/hl4150cdncupswrapper-1.1.1-5.i386.rpm"

LICENSE="brother-eula"

SLOT="0"

KEYWORDS="amd64"

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

	dosbin "${WORKDIR}/usr/bin/brprintconf_hl4150cdn"

	cp -r usr "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( cd "${D}/usr/libexec/cups/filter/" && ln -s ../../../../usr/local/Brother/Printer/hl4150cdn/lpd/filterhl4150cdn brlpdwrapperhl4150cdn ) || die

	mkdir -p "${D}/usr/share/cups/model" || die
	( cd "${D}/usr/share/cups/model" && ln -s ../../../../usr/local/Brother/Printer/hl4150cdn/cupswrapper/hl4150cdn.ppd ) || die
}
