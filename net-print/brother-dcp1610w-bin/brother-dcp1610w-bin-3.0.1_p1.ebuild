# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils rpm linux-info

BR_PN="${PN/brother-/}"
BR_PN="${BR_PN/-bin/}"
BR_PV="${PV/-${PR}/}"
BR_PV="${BR_PV/_p/-}"

MODEL="${BR_PN^^}"

DESCRIPTION="Brother printer driver for DCP-1610W"
HOMEPAGE="http://support.brother.com"
SRC_URI="http://download.brother.com/welcome/dlf101535/${BR_PN}lpr-${BR_PV}.i386.rpm
	http://download.brother.com/welcome/dlf101534/${BR_PN}cupswrapper-${BR_PV}.i386.rpm
	http://www.brother.com/pub/bsc/linux/dlf/dcp1510cupswrapper-GPL_src-${BR_PV}.tar.gz"

LICENSE="GPL-2 brother-eula no-source-code"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+metric debug"
RESTRICT="mirror strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}
	app-text/ghostscript-gpl
	app-text/a2ps"

S="${WORKDIR}"
PAPER_TYPE="Letter"
DEST="/opt/brother/Printers/${MODEL}"
CUPS_PPD_PATH="/usr/share/cups/model/brother"
CUPS_FILTER_PATH="/usr/libexec/cups/filter"
RC_FILE="br${MODEL}rc"
PPD_FILE="brother-${MODEL}-cups-en.ppd"
CUPS_WRAPPER="brother_lpdwrapper_${MODEL}"
SRC_LPR_DIR="${S}${DEST}"
SRC_CUPS_DIR="${S}/dcp1510cupswrapper-GPL_src-${BR_PV}"

pkg_setup() {
	CONFIG_CHECK=""
	if use amd64; then
		CONFIG_CHECK="${CONFIG_CHECK} ~IA32_EMULATION"
	fi

	linux-info_pkg_setup
}

src_prepare() {
	default

	# Install CUPS PPD and filter wrapper to their respective locations
	mkdir -p "${S}${CUPS_PPD_PATH}" || die "Creating CUPS PPD install location failed"
	mv "${SRC_LPR_DIR}/cupswrapper/${PPD_FILE}" "${S}${CUPS_PPD_PATH}/${MODEL}.ppd" || die "Preparing CUPS PPD file failed"
	mkdir -p "${S}${CUPS_FILTER_PATH}" || die "Creating CUPS filter wrapper install location failed"
	mv "${SRC_LPR_DIR}/cupswrapper/${CUPS_WRAPPER}" "${S}${CUPS_FILTER_PATH}" || die "Preparing CUPS filter wrapper failed"

	einfo "Fixing ${CUPS_WRAPPER} PPD file path"
	sed -i "s|/usr/share/cups/model/|${CUPS_PPD_PATH}/|" \
		"${S}${CUPS_FILTER_PATH}/${CUPS_WRAPPER}" || die "Fixing ${CUPS_WRAPPER} PPD file path failed"
}

src_configure() {
	if use metric; then
		PAPER_TYPE="A4"
	fi

	sed -ri "s/^(PaperType=).*$/\1${PAPER_TYPE}/" \
		"${SRC_LPR_DIR}/inf/${RC_FILE}" || die "Changing LPR paper type in rc file failed"

	if use debug; then
		sed -i -e 's:^\(DEBUG\)=0:\1=1:' \
			"${S}${CUPS_FILTER_PATH}/${CUPS_WRAPPER}" || die "Enabling CUPS filter wrapper debug output failed"
	fi
}

src_compile() {
	cd "${SRC_CUPS_DIR}/brcupsconfig"
	emake brcupsconfig
}

src_install() {
	insinto "${DEST}"
	doins -r "${SRC_LPR_DIR}/"* || die
	fperms -R 755 "${DEST}/lpd" || die
	fperms 755 "${DEST}/inf/braddprinter" || die
	fperms 755 "${DEST}/inf/setupPrintcap" || die

	exeinto "${DEST}/cupswrapper"
	newexe "${SRC_CUPS_DIR}/brcupsconfig/brcupsconfig" brcupsconfig4 || die

	insinto "${CUPS_PPD_PATH}"
	doins "${S}${CUPS_PPD_PATH}/"* || die

	exeinto "${CUPS_FILTER_PATH}"
	doexe "${S}${CUPS_FILTER_PATH}/"* || die
}

pkg_postinst() {
	elog "Set paper type to ${PAPER_TYPE} in ${DEST}/inf/${RC_FILE}."
	elog
	if use debug; then
		elog "Set DEBUG=1 in ${CUPS_FILTER_PATH}/${CUPS_WRAPPER}."
		elog
	fi
	elog "Debug output can be controlled setting the DEBUG var in"
	elog "${CUPS_FILTER_PATH}/${CUPS_WRAPPER}."
	elog "Allowed values go from 0 (no debug) to 4. The script is"
	elog "able to accept the option force-debug=<level 1 to 4>."
	elog
	elog "A log file will be saved in /tmp when DEBUG is set."
}
