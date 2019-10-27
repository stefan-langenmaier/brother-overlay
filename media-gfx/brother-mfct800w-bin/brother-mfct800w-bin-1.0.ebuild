# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Scanner driver for Brother MFC-T800W (brscan4)"
HOMEPAGE="http://support.brother.com"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="media-gfx/brother-scan4-bin"

pkg_postinst() {
	einfo "Configure scanner using one of the following commands:"
	einfo "- using hostname:   /usr/local/Brother/sane/brsaneconfig4 -a name=MFC-T800W model=MFC-T800W nodename=<hostname>"
	einfo "- using IP address: /usr/local/Brother/sane/brsaneconfig4 -a name=MFC-T800W model=MFC-T800W ip=<IP address>"
}
