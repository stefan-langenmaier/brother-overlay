# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit eutils rpm linux-info multilib

DESCRIPTION="Generic Brother printer driver"

HOMEPAGE="http://support.brother.com"

SRC_URI="http://download.brother.com/welcome/dlf101124/brgenml1lpr-3.1.0-1.i386.rpm
	http://download.brother.com/welcome/dlf101126/brgenml1cupswrapper-3.1.0-1.i386.rpm"

LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

IUSE="avahi"

RESTRICT="mirror strip"

DEPEND="net-print/cups
	avahi? ( net-dns/avahi
		sys-auth/nss-mdns )"
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
	# adapted from the archlinux package
	# https://aur.archlinux.org/packages/brother-brgenml1/
	epatch "${FILESDIR}/brother_lpdwrapper_BrGenML1.patch"
	default
}

src_install() {
	cp -r var "${D}" || die
	cp -r opt "${D}" || die
	cp -r etc "${D}" || die

	mkdir -p "${D}/usr/libexec/cups/filter" || die
	( cd "${D}/usr/libexec/cups/filter/" && ln -s ../../../../opt/brother/Printers/BrGenML1/cupswrapper/brother_lpdwrapper_BrGenML1 ) || die

	mkdir -p "${D}/usr/share/cups/model" || die
	( cd "${D}/usr/share/cups/model" && ln -s ../../../../opt/brother/Printers/BrGenML1/cupswrapper/brother-BrGenML1-cups-en.ppd ) || die
}

pkg_postinst() {
	einfo "If you don't use avahi with nss-mdns, you'll have to use a static IP address in your printer configuration"
	einfo "If you want to use a broadcasted name, add .local to it"
	einfo "You can test if it's working with ping printername.local"
}
