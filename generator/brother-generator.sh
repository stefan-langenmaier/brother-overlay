#!/bin/bash

# -----------------------------------
#  Created by Fonic
#  Date: 05/12/16
# -----------------------------------

# -----------------------------------
#  Configuration
# -----------------------------------

# Debugging switch
#DEBUGGING="true"

# Configuration for brscan2
BRSCAN2_COMMAND="brsaneconfig2 -q"
BRSCAN2_OUTDIR="brscan2"
BRSCAN2_NAME="brother-%id%-bin"
BRSCAN2_VERSION="1.0"
BRSCAN2_CATEGORY="media-gfx"
read -d '' BRSCAN2_EBUILD << EOD
# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Scanner driver for Brother %model% (brscan2)"
HOMEPAGE="http://support.brother.com"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="media-gfx/brother-scan2-bin"

pkg_postinst() {
	einfo "Configure scanner using one of the following commands:"
	einfo "- using hostname:   /usr/local/Brother/sane/brsaneconfig2 -a name=%model% model=%model% nodename=<hostname>"
	einfo "- using IP address: /usr/local/Brother/sane/brsaneconfig2 -a name=%model% model=%model% ip=<IP address>"
}
EOD

read -d '' BRSCAN2_METADATA << EOD
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
<pkgmetadata>
<longdescription>Scanner driver for Brother %model% (brscan2)</longdescription>
</pkgmetadata>
EOD

# Configuration for brscan3
BRSCAN3_COMMAND="brsaneconfig3 -q"
BRSCAN3_OUTDIR="brscan3"
BRSCAN3_NAME="brother-%id%-bin"
BRSCAN3_VERSION="1.0"
BRSCAN3_CATEGORY="media-gfx"
read -d '' BRSCAN3_EBUILD << EOD
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# \$Id\$

EAPI="6"

DESCRIPTION="Scanner driver for Brother %model% (brscan3)"
HOMEPAGE="http://support.brother.com"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="media-gfx/brother-scan3-bin"

pkg_postinst() {
	einfo "Configure scanner using one of the following commands:"
	einfo "- using hostname:   /usr/local/Brother/sane/brsaneconfig3 -a name=%model% model=%model% nodename=<hostname>"
	einfo "- using IP address: /usr/local/Brother/sane/brsaneconfig3 -a name=%model% model=%model% ip=<IP address>"
}
EOD

read -d '' BRSCAN3_METADATA << EOD
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
<!--
# \$Id\$
-->
<pkgmetadata>
<longdescription>Scanner driver for Brother %model% (brscan3)</longdescription>
</pkgmetadata>
EOD

# Configuration for brscan4
BRSCAN4_COMMAND="brsaneconfig4 -q"
BRSCAN4_OUTDIR="brscan4"
BRSCAN4_NAME="brother-%id%-bin"
BRSCAN4_VERSION="1.0"
BRSCAN4_CATEGORY="media-gfx"
read -d '' BRSCAN4_EBUILD << EOD
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# \$Id\$

EAPI="6"

DESCRIPTION="Scanner driver for Brother %model% (brscan4)"
HOMEPAGE="http://support.brother.com"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="media-gfx/brother-scan4-bin"

pkg_postinst() {
	einfo "Configure scanner using one of the following commands:"
	einfo "- using hostname:   /usr/local/Brother/sane/brsaneconfig4 -a name=%model% model=%model% nodename=<hostname>"
	einfo "- using IP address: /usr/local/Brother/sane/brsaneconfig4 -a name=%model% model=%model% ip=<IP address>"
}
EOD

read -d '' BRSCAN4_METADATA << EOD
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
<!--
# \$Id\$
-->
<pkgmetadata>
<longdescription>Scanner driver for Brother %model% (brscan4)</longdescription>
</pkgmetadata>
EOD

# Configuration for brgenml1
BRGENML1_MODELS="DCP-7055 DCP-7055W DCP-7060D DCP-7065DN DCP-7070DW DCP-8070D DCP-8085DN DCP-8110DN DCP-8250DN DCP-L2500D DCP-L2520DW DCP-L2540DN DCP-L2560DW HL-2130 HL-2135W HL-2240 HL-2240D HL-2250DN HL-2270DW HL-5340D HL-5350DN HL-5350DNLT HL-5370DW HL-5380DN HL-5440D HL-5450DN HL-5450DNT HL-5470DW HL-6180DW HL-6180DWT HL-L2300D HL-L2340DW HL-L2360DN HL-L2365DW MFC-7360N MFC-7460DN MFC-7860DW MFC-8370DN MFC-8380DN MFC-8510DN MFC-8520DN MFC-8880DN MFC-8890DW MFC-8950DW MFC-8950DWT MFC-L2700DW MFC-L2720DW MFC-L2740DW"
BRGENML1_OUTDIR="brgenml1"
BRGENML1_NAME="brother-%id%-bin"
BRGENML1_VERSION="1.0"
BRGENML1_CATEGORY="net-print"
read -d '' BRGENML1_EBUILD << EOD
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# \$Id\$

EAPI="6"

DESCRIPTION="Printer driver for Brother %model% (brgenml1)"
HOMEPAGE="http://support.brother.com"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="net-print/brother-genml1-bin"
EOD

read -d '' BRGENML1_METADATA << EOD
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pkgmetadata SYSTEM "http://www.gentoo.org/dtd/metadata.dtd">
<!--
# \$Id\$
-->
<pkgmetadata>
<longdescription>Generic printer driver for Brother %model% (brgenml1)</longdescription>
</pkgmetadata>
EOD


# -----------------------------------
#  Functions
# -----------------------------------

# Evaluate and print result [$?: exitcode]
function print_result() {
	if [ $? -eq 0 ]; then
		echo -e "\033[1;32mok\033[0m"
	else
		echo -e "\033[1;31merror\033[0m"
	fi
}

# Convert model to id [$1: model]
function model2id() {
	local id="$1"
	id=${id/-/}
	id=${id,,}
	echo $id
}

# Generate list of models supported by brscan [$@: query command]
function get_brscan_models() {
	local regex="[0-9]+ \"([A-Z0-9-]+)\""
	local line
	while read line; do
		if [[ $line =~ $regex ]]; then
			echo ${BASH_REMATCH[1]}
		fi
	done < <($@ 2>/dev/null)
}

# Generate meta package for model [$1: model, $2: output directory, $3: package name, $4: package version, $5: package category, $6: package ebuild, $7: package metadata]
function generate_meta_package() {
	local devmodel="$1"
	local devid=$(model2id "$devmodel")

	local pkgname=${3//%id%/$devid}
	local pkgfile="${pkgname}-${4}.ebuild"
	local pkgpath="${2}/${5}/${pkgname}"
	local pkgdata=${6//%model%/$devmodel}
	local pkgmetadata=${7//%model%/$devmodel}

	echo -en "Generating package for '\033[1m$1\033[0m'... "
	mkdir -p "$pkgpath" &>/dev/null && echo "$pkgdata" 2>/dev/null >"$pkgpath/$pkgfile" && echo "$pkgmetadata" 2>/dev/null >"$pkgpath/metadata.xml"
	print_result

	[ "$DEBUGGING" == "true" ] && echo -e "\033[1;33m*** DEBUG ***\n\033[0;1mmodel:\033[0m $devmodel, \033[1mid:\033[0m $devid, \033[1mname:\033[0m $pkgname, \033[1mfile:\033[0m $pkgfile, \033[1mpath:\033[0m $pkgpath\n\033[1mdata:\033[0m $pkgdata\n\033[1mmetadata:\033[0m $pkgmetadata\n"
}

# Generate ebuild manifest [$1: ebuild]
function generate_ebuild_manifest() {
	echo -en "Generating manifest for '\033[1m$(basename "$1" 2>/dev/null)\033[0m'... "
	ebuild "$1" manifest &>/dev/null
	print_result
}


# -----------------------------------
#  Main
# -----------------------------------

# Generate brscan2 packages
for model in $(get_brscan_models $BRSCAN2_COMMAND); do
	generate_meta_package "$model" "$BRSCAN2_OUTDIR" "$BRSCAN2_NAME" "$BRSCAN2_VERSION" "$BRSCAN2_CATEGORY" "$BRSCAN2_EBUILD" "$BRSCAN2_METADATA"
	[ "$DEBUGGING" == "true" ] && break
done

# Generate brscan3 packages
for model in $(get_brscan_models $BRSCAN3_COMMAND); do
	generate_meta_package "$model" "$BRSCAN3_OUTDIR" "$BRSCAN3_NAME" "$BRSCAN3_VERSION" "$BRSCAN3_CATEGORY" "$BRSCAN3_EBUILD" "$BRSCAN3_METADATA"
	[ "$DEBUGGING" == "true" ] && break
done

# Generate brscan4 packages
for model in $(get_brscan_models $BRSCAN4_COMMAND); do
	generate_meta_package "$model" "$BRSCAN4_OUTDIR" "$BRSCAN4_NAME" "$BRSCAN4_VERSION" "$BRSCAN4_CATEGORY" "$BRSCAN4_EBUILD" "$BRSCAN4_METADATA"
	[ "$DEBUGGING" == "true" ] && break
done

# Generate brgenml1 packages
for model in $BRGENML1_MODELS; do
	generate_meta_package "$model" "$BRGENML1_OUTDIR" "$BRGENML1_NAME" "$BRGENML1_VERSION" "$BRGENML1_CATEGORY" "$BRGENML1_EBUILD" "$BRGENML1_METADATA"
	[ "$DEBUGGING" == "true" ] && break
done

# Generate ebuild manifests
IFS=$'\n'
for ebuild in $(find -type f -name '*.ebuild' 2>/dev/null); do
	generate_ebuild_manifest "$ebuild"
done

# Count generated packages
echo -e "\n-> packages brscan2: $(find "$BRSCAN2_OUTDIR" -type f -name '*.ebuild' 2>/dev/null | wc -l 2>/dev/null), brscan3: $(find "$BRSCAN3_OUTDIR" -type f -name '*.ebuild' 2>/dev/null | wc -l 2>/dev/null), brscan4: $(find "$BRSCAN4_OUTDIR" -type f -name '*.ebuild' 2>/dev/null | wc -l 2>/dev/null), brgenml1: $(find "$BRGENML1_OUTDIR" -type f -name '*.ebuild' 2>/dev/null | wc -l 2>/dev/null), total: $(find -type f -name '*.ebuild' 2>/dev/null | wc -l 2>/dev/null)\n"
