# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils rpm linux-info multilib

DESCRIPTION="Brother printer driver for HL-3070CW"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf005916/hl3070cwlpr-1.1.2-1.i386.rpm
	http://download.brother.com/welcome/dlf005918/hl3070cwcupswrapper-1.1.2-2.i386.rpm"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

IUSE=""

RESTRICT="mirror strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

S=${WORKDIR}

pkg_setup() {
    CONFIG_CHECK=""
    if use amd64; then
	CONFIG_CHECK="${CONFIG_CHECK} ~IA32_EMULATION"
	if ! has_multilib_profile; then
	    die "This package CANNOT be installed on pure 64-bit system. You need multilib enabled."
	fi
    fi

    linux-info_pkg_setup
}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	has_multilib_profile && ABI=x86

	dobin "${WORKDIR}/usr/bin/brprintconf_hl3070cw"

	cp -r usr "${D}" || die
	cp -r opt "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	cp -a opt/brother/Printers/hl3070cw/lpd/filterhl3070cw "${D}/usr/libexec/cups/filter/brlpdwrapperhl3070cw" || die

	mkdir -p "${D}/usr/share/cups/model" || die
	cp -a opt/brother/Printers/hl3070cw/cupswrapper/brother_hl3070cw_printer_en.ppd "${D}/usr/share/cups/model/"  || die
}

pkg_postinst() {
    chmod 755 /opt/brother/Printers/hl3070cw/lpd
    chmod 755 /opt/brother/Printers/hl3070cw/inf
    chmod 755 /opt/brother/Printers/hl3070cw
    chmod 755 /opt/brother/Printers
    chmod 755 /opt/brother
}
