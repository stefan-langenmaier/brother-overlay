# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rpm

MY_PN="${PN/brother-/}"
MY_PN="${MY_PN/-bin/}"
MY_PV="${PV/_p/-}"

DESCRIPTION="Brother printer driver for MFC-6490CW"
HOMEPAGE="http://support.brother.com"
SRC_URI="https://download.brother.com/welcome/dlf006179/${MY_PN}lpr-${MY_PV}.i386.rpm
	https://download.brother.com/welcome/dlf006181/${MY_PN}cupswrapper-${MY_PV}.i386.rpm"
RESTRICT="mirror strip"

LICENSE="GPL-2 brother-eula"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="net-print/cups
	app-text/psutils
	app-text/ghostscript-gpl
	app-text/a2ps
	!net-print/brother-mfc6490cw-lpr
	!net-print/brother-mfc6490cw-cups"
DEPEND="net-print/cups"

S="${WORKDIR}"
INSTALL_SCRIPT="${S}/usr/local/Brother/Printer/${MY_PN}/cupswrapper/cupswrapper${MY_PN}"
PPD_PATH="${S}/usr/share/cups/model"
FILTER_PATH="${S}/usr/libexec/cups/filter"

src_prepare() {
	default

	sed -i 's|device_model="Printer"|device_model="Printers"|' "${S}/usr/local/Brother/Printer/${MY_PN}/cupswrapper/cupswrapper${MY_PN}" || die
	sed -i 's|/usr/local/Brother|/opt/brother|' "${S}/usr/local/Brother/Printer/${MY_PN}/cupswrapper/cupswrapper${MY_PN}" || die
	sed -i 's|/usr/local/Brother/Printer/|/opt/brother/Printers/|' "${S}/usr/local/Brother/Printer/${MY_PN}/lpd/filter${MY_PN}" || die
	sed -i 's|/usr/local/Brother/Printer/|/opt/brother/Printers/|' "${S}/usr/local/Brother/Printer/${MY_PN}/inf/setupPrintcapij" || die

	local installScriptNew="${S}/install.sh"

	echo '#!/bin/sh' >"${installScriptNew}"

	egrep '(printer_model|printer_name|device_name|pcfilename|device_model)=' "${INSTALL_SCRIPT}" >>"${installScriptNew}" || die "Extracting variables failed"

	echo "ppd_file_name=${PPD_PATH}/br\${printer_model}.ppd" >>"${installScriptNew}"
	sed -n '/cat <<ENDOFPPDFILE1/,/ENDOFPPDFILE1/p' "${INSTALL_SCRIPT}" >>"${installScriptNew}" || die "Creating PPD file failed"

	echo "brotherlpdwrapper=${FILTER_PATH}/brlpdwrapper\${printer_model}" >>"${installScriptNew}"
	sed -n '/cat <<!ENDOFWFILTER!/,/!ENDOFWFILTER!/p' "${INSTALL_SCRIPT}" >>"${installScriptNew}" || die "Creating filter wrapper failed"

	# Overwrite original INSTALL script
	mv "${installScriptNew}" "${INSTALL_SCRIPT}"

	mkdir -p "${PPD_PATH}"
	mkdir -p "${FILTER_PATH}"
	"/bin/sh" "${INSTALL_SCRIPT}" || die "Installation failed"
}

src_configure() {
	if use debug; then
		sed -i -e 's:^\(DEBUG\)=0:\1=1:' "${FILTER_PATH}/brlpdwrapper"* || die "Enabling debug output failed"
	fi
}

src_install() {
	rm -f "${INSTALL_SCRIPT}" || die
	insinto "/opt/brother/Printers"
	doins -r "usr/local/Brother/Printer/${MY_PN}" || die
	fperms -R 755 "/opt/brother" || die

	insinto "/usr/share/cups"
	doins -r "${PPD_PATH}" || die

	insinto "/usr/libexec/cups"
	doins -r "${FILTER_PATH}" || die
	fperms -R 755 "/usr/libexec/cups/filter" || die

	dobin "usr/bin/brprintconf_mfc6490cw" || die

	# Patch binary files: update .rodata with /opt/brother/Printers path
	objcopy --update-section .rodata="${FILESDIR}/brprintconf_mfc6490cw-${PV}.rodata" "${D}/usr/bin/brprintconf_mfc6490cw" || die
	objcopy --update-section .rodata="${FILESDIR}/brmfc6490cwfilter-${PV}.rodata" "${D}/opt/brother/Printers/${MY_PN}/lpd/brmfc6490cwfilter" || die
}

pkg_postinst() {
	ewarn "Printer setup required"
	elog "Use the brprintconf_${MY_PN} command to change printer options."
	elog "For example, set the paper type to A4 right after installation"
	elog "otherwise your prints will be misaligned!"
	elog
	elog "To set A4 paper type:"
	elog "	brprintconf_${MY_PN} -pt A4"
	elog "To set quality to 'Fast Normal':"
	elog "	brprintconf_${MY_PN} -reso 300x300dpi"
	elog "To get an overview of all available options:"
	elog "	brprintconf_${MY_PN}"
}
