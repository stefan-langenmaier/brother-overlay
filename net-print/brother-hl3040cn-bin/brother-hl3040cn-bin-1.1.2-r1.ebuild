# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm multilib

DESCRIPTION="Brother printer driver for HL-3040CN"

HOMEPAGE="http://support.brother.com"

SRC_URI="https://download.brother.com/welcome/dlf005904/hl3040cnlpr-1.1.2-1.i386.rpm
	https://download.brother.com/welcome/dlf005906/hl3040cncupswrapper-1.1.2-2.i386.rpm"

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

	dosbin "${WORKDIR}/usr/bin/brprintconf_hl3040cn"

	cp -r opt "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( cd "${D}/usr/libexec/cups/filter/" && ln -s /opt/brother/Printers/hl3040cn/lpd/filterhl3040cn brlpdwrapperhl3040cn ) || die

	mkdir -p "${D}/usr/share/ppd/cupsfilters" || die
	( cd "${D}/usr/share/ppd/cupsfilters" && ln -s /opt/brother/Printers/hl3040cn/cupswrapper/brother_hl3040cn_printer_en.ppd ) || die
}
