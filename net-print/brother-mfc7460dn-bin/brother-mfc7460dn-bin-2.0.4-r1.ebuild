# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit rpm linux-info multilib

DESCRIPTION="Brother MFC-7460DN printer driver"
HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf006257/mfc7460dnlpr-2.1.0-1.i386.rpm
	http://download.brother.com/welcome/dlf006259/cupswrapperMFC7460DN-2.0.4-2.i386.rpm"

LICENSE="brother-eula GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="net-print/cups"

RESTRICT="strip"
QA_PREBUILT="opt/brother/Printers/MFC7460DN/inf/brprintconflsr3
	opt/brother/Printers/MFC7460DN/lpd/rawtobr3"
S="${WORKDIR}/usr/local/Brother/Printer/MFC7460DN"

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

src_prepare() {
	default
	sed -i -f "${FILESDIR}/fix-paths.sed" "${S}/cupswrapper/cupswrapperMFC7460DN-${PV}" || die
	sed -i -f "${FILESDIR}/fix-paths.sed" "${S}/inf/setupPrintcap2" || die
	sed -i -f "${FILESDIR}/fix-paths.sed" "${S}/lpd/filterMFC7460DN" || die
	sed -z -i -f "${FILESDIR}/fix-paths-in-binary.sed" "${S}/cupswrapper/brcupsconfig4" || die
	sed -z -i -f "${FILESDIR}/fix-paths-in-binary.sed" "${S}/inf/braddprinter" || die
	sed -z -i -f "${FILESDIR}/fix-paths-in-binary.sed" "${S}/inf/brprintconflsr3" || die
	sed -f "${FILESDIR}/extract-cups-ppd.sed" "${S}/cupswrapper/cupswrapperMFC7460DN-${PV}" > "${T}/brother-MFC7460DN.ppd" || die
	sed -f "${FILESDIR}/extract-cups-filter.sed" "${S}/cupswrapper/cupswrapperMFC7460DN-${PV}" > "${T}/brlpdwrapperMFC7460DN" || die
}

src_install() {
	keepdir /var/spool/lpd/MFC7460DN
	dodir /opt/brother/Printers
	cp -a "${S}" "${ED%/}/opt/brother/Printers" || die
	fowners lp:lp /opt/brother/Printers/MFC7460DN/inf/brMFC7460DNrc
	fperms 600 /opt/brother/Printers/MFC7460DN/inf/brMFC7460DNrc
	insinto /opt/brother/Printers/MFC7460DN/cupswrapper
	doins "${T}/brother-MFC7460DN.ppd"
	exeinto /opt/brother/Printers/MFC7460DN/cupswrapper
	doexe "${T}/brlpdwrapperMFC7460DN"
	dosym ../../../../opt/brother/Printers/MFC7460DN/cupswrapper/brother-MFC7460DN.ppd /usr/share/cups/model/brother-MFC7460DN.ppd
	dosym ../../../../opt/brother/Printers/MFC7460DN/cupswrapper/brlpdwrapperMFC7460DN /usr/libexec/cups/filter/brlpdwrapperMFC7460DN
}
