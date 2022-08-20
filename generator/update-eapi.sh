#!/bin/bash
# Commands used to update all EAPI to EAPI 8
# File created for archive and helping future updaters, DO NOT use as it

# working folder
folder="net-print"
# Update Copyright, get last copyright from /var/db/repos/gentoo/skel.ebuild
sed -i '1,2c\# Copyright 1999-2022 Gentoo Authors\n# Distributed under the terms of the GNU General Public License v2' "${folder}/*/*.ebuild"
# Update EAPI
sed -i "/^EAPI=/c\EAPI=8" "${folder}/*/*.ebuild"
# eutils is integrated since EAPI 7 and not more necessary
sed -i 's/inherit eutils/inherit/' "${folder}/*/*.ebuild"

# Add -r1 to ebuild names
# this won't work for future updates, as all ebuilds have ever a revision number, will need to adapt this loop to change "-rX" to "-r(X+1) in ebuild names"
FOLD=( `ls ${folder}` )
for fold in ${FOLD[*]}; do FILES=( `ls "${fold}" | grep ebuild` ); for file in ${FILES[*]}; do mv "${fold}/${file}" "${fold}/${file%.*}-r1.ebuild"; done; done
# Adapt calculated BR_PR
sed -i 's/${BR_PR}-1/${BR_PR}-2/' "${folder}/*/*.ebuild"

# re-execute all commands with
folder="media-gfx"
