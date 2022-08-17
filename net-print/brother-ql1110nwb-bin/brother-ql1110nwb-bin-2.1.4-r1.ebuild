# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm multilib

DESCRIPTION="Printer driver for Brother QL-1110NWB"

HOMEPAGE="http://support.brother.com"

SRC_URI="https://download.brother.com/welcome/dlfp100576/ql1110nwbpdrv-2.1.4-0.i386.rpm"

LICENSE="brother-eula"
SLOT="0"
KEYWORDS="amd64 x86"
RESTRICT="strip"

DEPEND="net-print/cups"
RDEPEND="${DEPEND}
	app-text/ghostscript-gpl
"
S=${WORKDIR}

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	has_multilib_profile && ABI=x86

	cp -r usr "${D}" || die
	cp -r opt "${D}" || die

	mkdir -p "${D}/usr/lib/cups/filter" || die
	mkdir -p "${D}/usr/share/cups/model" || die

	_cupswrapper_script="${D}/opt/brother/PTouch/ql1110nwb/cupswrapper/cupswrapperql1110nwb" || die
	sed -i '/lpadmin/d' "${_cupswrapper_script}" || die
	sed -i 's|/usr/share/cups/model/Brother|/usr/share/cups/model|g' "${_cupswrapper_script}" || die
	sed -i 's|^\s\+/etc/init.d|echo /etc/init.d|g' "${_cupswrapper_script}" || die
	sed -i 's|/usr|$D/usr|g' "${_cupswrapper_script}" || die
	sed -i 's|/opt|$D/opt|g' "${_cupswrapper_script}" || die
	sed -i 's|lpinfo -v|echo|g' "${_cupswrapper_script}" || die
	sed -i '/^sleep/d' "${_cupswrapper_script}" || die
	sed -i 's|brotherlpdwrapper=$D|brotherlpdwrapper=|g' "${_cupswrapper_script}" || die
	export D || die
	/bin/sh "${_cupswrapper_script}" || die
	rm -f "${_cupswrapper_script}" || die

	mv "${D}/usr/lib" "${D}/usr/libexec" || die
}
