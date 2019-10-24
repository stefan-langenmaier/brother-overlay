# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm

MY_PN="${PN/brother-/}"
MY_PN="${MY_PN/-bin/}"
MY_PV="${PV/-${PR}/}"
MY_PV="${MY_PV/_p/-}"

DESCRIPTION="Brother printer driver for MFC-6490CW"
HOMEPAGE="http://support.brother.com"
SRC_URI="https://download.brother.com/welcome/dlf006179/${MY_PN}lpr-${MY_PV}.i386.rpm
	https://download.brother.com/welcome/dlf006678/brcups_ink4_src_${MY_PV%-*}-x.tar.gz"

LICENSE="GPL-2 brother-eula no-source-code"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+metric debug"
RESTRICT="mirror strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}
	app-text/psutils
	app-text/ghostscript-gpl
	app-text/a2ps
	!net-print/brother-mfc6490cw-lpr
	!net-print/brother-mfc6490cw-cups"

S="${WORKDIR}"
DEST="/opt/brother/Printers/${MY_PN}"
SRC_LPR_DIR="${S}/usr/local/Brother/Printer/${MY_PN}"
SRC_CUPS_DIR="${S}/cupswrapper${MY_PN}_src"
CUPS_INSTALL_SCRIPT="${SRC_CUPS_DIR}/SCRIPT/cupswrapper${MY_PN}"
CUPS_PPD_PATH="${S}/usr/share/cups/model"
CUPS_FILTER_PATH="${S}/usr/libexec/cups/filter"

src_unpack() {
	rpm_unpack "${MY_PN}lpr-${MY_PV}.i386.rpm"
	unpack "brcups_ink4_src_${MY_PV%-*}-x.tar.gz"
	unpack "${S}/brcups_ink4_src_${MY_PV%-*}-x/cupswrapper${MY_PN}_src-${MY_PV}.tar.gz"
}

src_prepare() {
	default

	# Create CUPS PPD and filter wrapper installation script
	local cupswrapper_install="${S}/cupswrapper${MY_PN}-install.sh"

	echo '#!/bin/sh' > "${cupswrapper_install}"

	egrep '(printer_model|printer_name|device_name|pcfilename|device_model)=' "${CUPS_INSTALL_SCRIPT}" >> "${cupswrapper_install}" || die "Extracting CUPS variables failed"

	echo "ppd_file_name=${CUPS_PPD_PATH}/br\${printer_model}.ppd" >> "${cupswrapper_install}"
	sed -n '/cat <<ENDOFPPDFILE1/,/ENDOFPPDFILE1/p' "${CUPS_INSTALL_SCRIPT}" >> "${cupswrapper_install}" || die "Creating CUPS PPD installation failed"

	echo "brotherlpdwrapper=${CUPS_FILTER_PATH}/brlpdwrapper\${printer_model}" >> "${cupswrapper_install}"
	sed -n '/cat <<!ENDOFWFILTER!/,/!ENDOFWFILTER!/p' "${CUPS_INSTALL_SCRIPT}" >> "${cupswrapper_install}" || die "Creating CUPS filter wrapper installation failed"

	# Install CUPS PPD and filter wrapper to their respective locations
	mkdir -p "${CUPS_PPD_PATH}" || die "Creating CUPS PPD install location failed"
	mkdir -p "${CUPS_FILTER_PATH}" || die "Creating CUPS filter wrapper install location failed"
	"/bin/sh" "${cupswrapper_install}" || die "Installing CUPS PPD and filter wrapper failed"
}

src_configure() {
	if use metric; then
		sed -i '/^PaperType/s/Letter/A4/' "${SRC_LPR_DIR}/inf/br${MY_PN}rc" || die "Changing LPR paper type in rc file failed"
	fi

	if use debug; then
		sed -i -e 's:^\(DEBUG\)=0:\1=1:' "${CUPS_FILTER_PATH}/brlpdwrapper${MY_PN}" || die "Enabling CUPS filter wrapper debug output failed"
	fi
}

src_compile() {
	cd "${SRC_CUPS_DIR}/brcupsconfigpt1"
	emake brcupsconfig
}

src_install() {
	into "/usr"
	dobin "usr/bin/"* || die

	insinto "${DEST}"
	doins -r "${SRC_LPR_DIR}/"* || die
	fperms -R 755 "${DEST}/lpd" || die
	fperms 755 "${DEST}/inf/setupPrintcapij" || die

	exeinto "${DEST}/cupswrapper"
	newexe "${SRC_CUPS_DIR}/brcupsconfigpt1/brcupsconfig" brcupsconfpt1 || die

	insinto "/usr/share/cups"
	doins -r "${CUPS_PPD_PATH}" || die

	exeinto "/usr/libexec/cups/filter"
	doexe "${CUPS_FILTER_PATH}/"* || die

	# Change hardcoded paths: /usr/local/Brother/Printer -> /opt/brother/Printers

	# Change hardcoded paths in LPR and CUPS scripts
	sed -i 's|/usr/local/Brother/Printer/|/opt/brother/Printers/|' \
		"${ED}/${DEST}/lpd/filter${MY_PN}" \
		"${ED}/${DEST}/inf/setupPrintcapij" \
		"${ED}/usr/libexec/cups/filter/"* || die "Changing hardcoded paths in LPR/CUPS scripts failed"

	# Change hardcoded paths in LPR proprietary binary files, no source available
	objcopy --update-section .rodata="${FILESDIR}/br${MY_PN}filter-${PV}.rodata" \
		"${ED}/${DEST}/lpd/br${MY_PN}filter" || die "Patching LPR binary br${MY_PN}filter failed"
	objcopy --update-section .rodata="${FILESDIR}/brprintconf_${MY_PN}-${PV}.rodata" \
		"${ED}/usr/bin/brprintconf_${MY_PN}" || die "Patching LPR binary brprintconf_${MY_PN} failed"
}

pkg_postinst() {
	elog "Use brprintconf_${MY_PN} to change printer options."
	elog
	ewarn "Right after installation use brprintconf_${MY_PN} to set"
	ewarn "the paper type to the kind you use, otherwise your prints"
	ewarn "may end up misaligned."
	elog
	elog "To set A4 paper type:"
	elog "	brprintconf_${MY_PN} -pt A4"
	elog "To set quality to 'Fast Normal':"
	elog "	brprintconf_${MY_PN} -reso 300x300dpi"
	elog "To get an overview of all available options:"
	elog "	brprintconf_${MY_PN}"
}
