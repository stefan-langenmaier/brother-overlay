# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm multilib

PRINTER_MODEL=${PN#*-}
PRINTER_MODEL=${PRINTER_MODEL%-*}

DESCRIPTION="Brother printer driver for MFC-J6955DW"
HOMEPAGE="https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=${PRINTER_MODEL}_us_eu_as"
SRC_URI="https://download.brother.com/welcome/dlf105480/${PRINTER_MODEL}pdrv-${PV}-1.i386.rpm"

RESTRICT="mirror strip"

LICENSE="GPL-2+ brother-eula"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+metric"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_prepare() {
	default

	if use metric; then
		sed -i '/^PageSize/s/Letter/A4/' \
			"${S}"/opt/brother/Printers/${PRINTER_MODEL}/inf/br${PRINTER_MODEL}rc || die
	fi
}

src_install() {
	local arch
	if use amd64; then
		arch="x86_64"
	else
		arch="i686"
	fi

	# Install inf (configuration) files
	insinto /opt/brother/Printers/${PRINTER_MODEL}/inf
	doins "${S}"/opt/brother/Printers/${PRINTER_MODEL}/inf/*

	# Install lpd filter scripts and arch-specific binaries
	exeinto /opt/brother/Printers/${PRINTER_MODEL}/lpd
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/lpd/filter_${PRINTER_MODEL}
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/lpd/${arch}/br${PRINTER_MODEL}filter

	# Printer configuration utility
	dobin "${S}"/opt/brother/Printers/${PRINTER_MODEL}/lpd/${arch}/brprintconf_${PRINTER_MODEL}

	# Install CUPS wrapper and PPD
	exeinto /opt/brother/Printers/${PRINTER_MODEL}/cupswrapper
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/cupswrapper${PRINTER_MODEL}
	doexe "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_lpdwrapper_${PRINTER_MODEL}

	# Symlink the CUPS filter
	dosym /opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_lpdwrapper_${PRINTER_MODEL} \
		/usr/libexec/cups/filter/brother_lpdwrapper_${PRINTER_MODEL}

	# Install PPD file
	insinto /usr/share/ppd/Brother
	doins "${S}"/opt/brother/Printers/${PRINTER_MODEL}/cupswrapper/brother_${PRINTER_MODEL}_printer_en.ppd
}

pkg_postinst() {
	einfo "To add the printer, use CUPS web interface at http://localhost:631"
	einfo "or run: lpadmin -p MFC-J6955DW -E -v <device_uri> -m Brother/brother_${PRINTER_MODEL}_printer_en.ppd"
}
