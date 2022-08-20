# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit rpm

model="mfcj985dw"
wrapper_source="${model}_cupswrapper_GPL_source_${PV}-0"

DESCRIPTION="CUPS driver for the Brother MFC-J985DW"
HOMEPAGE="http://support.brother.com"
SRC_URI="
	https://download.brother.com/welcome/dlf102746/${model}lpr-${PV}-0.i386.rpm
	https://download.brother.com/welcome/dlf102750/${wrapper_source}.tar.gz
"

LICENSE="brother-eula GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="net-print/cups"

S="${WORKDIR}"

QA_PRESTRIPPED="
	/opt/brother/Printers/${model}/lpd/br${model}filter
	/usr/bin/brprintconf_${model}
"

src_compile() {
	emake -C "${wrapper_source}/brcupsconfig"
}

src_install() {
	# lpr
	dobin usr/bin/brprintconf_${model}
	local exe
	insinto /opt/brother/Printers/${model}
	doins -r "${WORKDIR}"/opt/brother/Printers/${model}/.
	for exe in br${model}filter filter${model} psconvertij2; do
		fperms 0755 /opt/brother/Printers/${model}/lpd/${exe}
	done
	# wrapper
	exeinto /opt/brother/Printers/${model}/cupswrapper
	doexe "${wrapper_source}"/brcupsconfig/brcupsconfpt1
	insinto /usr/share/cups/model
	doins "${wrapper_source}"/ppd/brother_${model}_printer_en.ppd
	# generated filter taken from the Arch User Repository package
	exeinto /usr/libexec/cups/filter
	doexe "${FILESDIR}"/brother_lpdwrapper_${model}
}
