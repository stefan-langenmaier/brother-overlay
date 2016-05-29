# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

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

src_prepare() {
	# adapted from the archlinux package
	# https://aur.archlinux.org/packages/brother-brgenml1/
	#epatch "${FILESDIR}/brother_lpdwrapper_BrGenML1.patch"
	return
}

src_install() {
	mkdir -p "${D}/usr/local/Brother/Printer/dcp9055cdn/cupswrapper" || die
	cp -r usr "${D}" || die

	chmod 755 "${D}/usr/local/Brother/Printer/dcp9055cdn/lpd" || die
	chmod 755 "${D}/usr/local/Brother/Printer/dcp9055cdn/inf" || die
	chmod 755 "${D}/usr/local/Brother/Printer/dcp9055cdn/" || die
	chmod 755 "${D}/usr/local/Brother/Printer/" || die
	chmod 755 "${D}/usr/local/Brother" || die

	"${D}/usr/local/Brother/Printer/dcp9055cdn/cupswrapper/cupswrapperdcp9055cdn" || die
	chmod 755 "${D}/usr/local/Brother/Printer/dcp9055cdn/cupswrapper" || die

	mkdir -p "${D}/var/spool/lpd" || die
	mkdir -p "${D}/usr/lib64/cups/filter" || die
	( ln -s "${D}/usr/lib64/cups/filter/brlpdwrapperdcp9055cdn" "${D}/usr/libexec/cups/filter/brlpdwrapperdcp9055cdn" ) || die
}

pkg_postinst() {
	einfo "Brother DCP-9055CDN printer installed"
}
