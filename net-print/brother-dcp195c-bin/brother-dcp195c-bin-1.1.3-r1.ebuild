# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm linux-info multilib

BR_PR=${PR/r/}
MY_PN=dcp195c

DESCRIPTION="Brother printer driver for DCP-195C"
HOMEPAGE="http://support.brother.com"
SRC_URI="https://download.brother.com/pub/com/linux/linux/packages/${MY_PN}cupswrapper-${PV}-${BR_PR}.i386.rpm
	https://download.brother.com/pub/com/linux/linux/packages/${MY_PN}lpr-${PV}-${BR_PR}.i386.rpm"

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
	MODEL="dcp195c"

	eapply ${FILESDIR}/cupswrapperdcp195c.patch

	mkdir -p "${WORKDIR}/var/tmp" || die
	${WORKDIR}/opt/brother/Printers/${MODEL}/cupswrapper/cupswrapper${MODEL} -i
	mv "${WORKDIR}/var/tmp/brlpdwrapper${MODEL}" "${WORKDIR}/opt/brother/Printers/${MODEL}/cupswrapper/brlpdwrapper${MODEL}"

	eapply_user
}

src_install() {

	cp -r opt "${D}" || die
	
	mkdir -p "${D}/usr/share/cups/model/Brother" || die
	cd "${D}/usr/share/cups/model/Brother/"
	ln -s "../../../../../opt/brother/Printers/${MODEL}/cupswrapper/brother_${MODEL}_printer_en.ppd" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
        cd "${D}/usr/libexec/cups/filter/"
	ln -s ../../../../opt/brother/Printers/${MODEL}/cupswrapper/brlpdwrapper${MODEL} || die
}



