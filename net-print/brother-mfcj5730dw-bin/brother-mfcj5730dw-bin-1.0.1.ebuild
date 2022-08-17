# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# updated from my Brother MFC-J880DW ebuild by Chris Morgenstern

EAPI=8

inherit rpm multilib

MODEL="mfcj5730dw"
BUILD="0"

DESCRIPTION="Brother MFC-J5730DW lpr+cupswrapper (printer) drivers"
HOMEPAGE="https://support.brother.com"
SRC_URI="https://download.brother.com/welcome/dlf103005/${MODEL}lpr-${PV}-${BUILD}.i386.rpm
		https://download.brother.com/welcome/dlf103029/${MODEL}cupswrapper-${PV}-${BUILD}.i386.rpm"
LICENSE="GPL-2+ brother-eula no-source-code"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+metric -debug"
RESTRICT="strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}"

DEST="/opt/brother/Printers/${MODEL}"
S="${WORKDIR}${DEST}"

src_prepare() {
	eapply_user

	if use metric; then
		sed -i '/^PaperType/s/Letter/A4/' inf/br${MODEL}rc || die
	fi

	if use debug; then
		sed -i '/^DEBUG=/s/.$/1/' cupswrapper/brother_lpdwrapper_${MODEL} || die
	fi
}

src_install() {
	has_multilib_profile && ABI=x86

	cd cupswrapper || die
	exeinto ${DEST}/cupswrapper
	doexe brother_lpdwrapper_${MODEL}
	dosym ${DEST}/cupswrapper/brother_lpdwrapper_${MODEL} /usr/libexec/cups/filter/brother_lpdwrapper_${MODEL}
	insinto ${DEST}/cupswrapper
	doins brother_${MODEL}_printer_en.ppd
	insinto /usr/share/cups/model/Brother
	doins brother_${MODEL}_printer_en.ppd
	insinto /usr/share/ppd/Brother
	doins brother_${MODEL}_printer_en.ppd

	# proprietary binary, no source available
	cd ../lpd || die
	exeinto ${DEST}/lpd
	doexe br${MODEL}filter filter_${MODEL}

	cd ../inf || die
	insinto ${DEST}/inf
	doins -r lut br${MODEL}rc br${MODEL}func ImagingArea PaperDimension paperinfij2

	# proprietary binary, no source available
	cd "${WORKDIR}/usr/bin" || die
	into /usr
	dobin brprintconf_${MODEL}
}

pkg_postinst () {
	ewarn "Because /usr/bin/brprintconf_${MODEL} uses /var/tmp to create a simple temp file on printing, make sure the directory has enough rights (eg. 1777)"
	ewarn "or you won't be able to change print options on printing and therefore you always have to edit /opt/brother/Printers/inf/br${MODEL}rc, manually!"
}
