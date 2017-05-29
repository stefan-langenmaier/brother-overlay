# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Brother driver support for MFC-7460DN"
HOMEPAGE="http://support.brother.com"
SRC_URI=""
LICENSE="brother-eula GPL-2"

SLOT="0"

KEYWORDS="amd64 x86"

IUSE="+scanner +printer"

DEPEND=""
RDEPEND="${DEPEND}
	printer? ( net-print/brother-genml1-bin )
	scanner? ( media-gfx/brother-scan4-bin )"

pkg_postinst() {

	if use printer ; then
		einfo "If you don't use avahi with nss-mdns you have to use a static IP addresss in your printer configuration"
		einfo "If you want to use a broadcasted name add .local to it"
		einfo "You can test if it's working with ping printername.local"
	fi

	if use scanner ; then
		einfo "Configure scanner:"
		einfo "- using hostname:   /usr/local/Brother/sane/brsaneconfig3 -a name=%model% model=%model% nodename=<hostname>"
		einfo "- using IP address: /usr/local/Brother/sane/brsaneconfig3 -a name=%model% model=%model% ip=<IP address>"
	fi
}
