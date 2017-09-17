# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils versionator rpm linux-info

MY_VERSION=$(replace_version_separator 3 '-')
MY_PRINTER=${PN#*-}
MY_PRINTER=${MY_PRINTER%-*}
PRINTER_NAME=${MY_PRINTER^^}

DESCRIPTION="Brother printer driver for ${PRINTER_NAME}"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf005663/${MY_PRINTER}lpr-${MY_VERSION}.i386.rpm
	http://download.brother.com/welcome/dlf005665/${MY_PRINTER}cupswrapper-${MY_VERSION}.i386.rpm"

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
	perl -i -pe 'BEGIN{$stop=0} $stop = !$stop if /ENDOFWFILTER/; if(!$stop) {s/\$1/\$2/g;s!/usr!\$1/usr!;s!/etc!\$1/etc!}' \
	  "usr/local/Brother/Printer/${MY_PRINTER}/cupswrapper/cupswrapperSetup_${MY_PRINTER}"
}

src_install() {
	mkdir -p "${D}/usr/local/Brother/Printer/${MY_PRINTER}/cupswrapper" || die
	mkdir -p "${D}/usr/lib/cups/filter" || die
	mkdir -p "${D}/usr/share/ppd" || die
	cp -r usr "${D}" || die

	chmod 755 "${D}/usr/local/Brother/Printer/${MY_PRINTER}/lpd" || die
	chmod 755 "${D}/usr/local/Brother/Printer/${MY_PRINTER}/inf" || die
	chmod 755 "${D}/usr/local/Brother/Printer/${MY_PRINTER}/" || die
	chmod 755 "${D}/usr/local/Brother/Printer/" || die
	chmod 755 "${D}/usr/local/Brother" || die

	"${D}/usr/local/Brother/Printer/${MY_PRINTER}/cupswrapper/cupswrapperSetup_${MY_PRINTER}" "${D}" || die
	chmod 755 "${D}/usr/local/Brother/Printer/${MY_PRINTER}/cupswrapper" || die

	mkdir -p "${D}/var/spool/lpd" || die
	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( ln -s "${D}/usr/lib64/cups/filter/brlpdwrapper${MY_PRINTER}" "${D}/usr/libexec/cups/filter/brlpdwrapper${MY_PRINTER}" ) || die
}

pkg_postinst() {
	einfo "Brother ${PRINTER_NAME} printer installed"
}
