# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit eutils rpm linux-info multilib

DESCRIPTION="Brother printer driver for HL1110* HL1112*"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf100418/hl1110lpr-3.0.1-1.i386.rpm
	http://download.brother.com/welcome/dlf100420/hl1110cupswrapper-3.0.1-1.i386.rpm"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

IUSE="avahi"

RESTRICT="mirror strip"

DEPEND="net-print/cups
	avahi? ( net-dns/avahi
		sys-auth/nss-mdns )"
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
	dosbin "${WORKDIR}/opt/brother/Printers/HL1110/lpd/brprintconflsr3"

	cp -r opt "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( cd "${D}/usr/libexec/cups/filter/" && ln -s ../../../../opt/brother/Printers/HL1110/lpd/filter_HL1110 brother_lpdwrapper_HL1110 ) || die

	mkdir -p "${D}/usr/share/cups/model" || die
	( cd "${D}/usr/share/cups/model" && ln -s ../../../../opt/brother/Printers/HL1110/cupswrapper/brother-HL1110-cups-en.ppd ) || die
}

pkg_postinst() {
	einfo "If you don't use avahi with nss-mdns, you'll have to use a static IP address in your printer configuration"
	einfo "If you want to use a broadcasted name, add .local to it"
	einfo "You can test if it's working with ping printername.local"
}
