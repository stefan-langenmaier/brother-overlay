# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils rpm linux-info

DESCRIPTION="Brother printer driver for MFC-7820N"

HOMEPAGE="http://support.brother.com"

MY_PR=${PR/r/}

SRC_URI="http://download.brother.com/welcome/dlf006265/brmfc7820nlpr-${PV}-${MY_PR}.i386.rpm
	http://download.brother.com/welcome/dlf006267/cupswrapperMFC7820N-${PV}-${MY_PR}.i386.rpm"

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
	"usr/local/Brother/cupswrapper/cupswrapperMFC7820N-${PV}"

	eapply_user
}

src_install() {
	cp -r usr "${D}" || die

	chmod 755 "${D}/usr/local/Brother/lpd" || die
	chmod 755 "${D}/usr/local/Brother/inf" || die
	chmod 755 "${D}/usr/local/Brother" || die

	"${D}/usr/local/Brother/cupswrapper/cupswrapperMFC7820N-${PV}" "${D}" || die
	chmod 755 "${D}/usr/local/Brother/cupswrapper" || die

	mkdir -p "${D}/var/spool/lpd/MFC7820N" || die
	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( ln -s "${D}/usr/lib/cups/filter/brlpdwrapperMFC7820N" "${D}usr/libexec/cups/filter/brlpdwrapperMFC7820N" ) || die
}

pkg_postinst() {
	einfo "Brother MFC-7820N printer installed"
}
