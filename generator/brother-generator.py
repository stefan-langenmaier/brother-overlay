#!/usr/bin/env python

import configparser
import re
from collections import defaultdict
from pathlib import Path

import jinja2
import portage

BROTHER_PKG_BASEURL = "https://download.brother.com/pub/com/linux/linux/packages"


def normalize_commercial_name(printer_name):
    """
    Example:
        >>> normalize_commercial_name("HLL2400DWE")
        'HL-L2400DWE'
    """
    if "-" in printer_name:
        return printer_name
    return printer_name.replace("MFC", "MFC-").replace("DCP", "DCP-").replace("HL", "HL-")


def get_version(filename):
    match = re.search(
        r".*-(?P<version>[\d\.]+)-(?P<build>\d)(\.\w+)?\.(?P<arch>[a-z0-9_]+)\.rpm", filename
    )
    if match:
        return match.group("version"), match.group("build")
    print("Could not match", filename)
    raise Exception


def build_template_vars(model_data):
    model_name = model_data["PRINTERNAME"].lower()
    cupswrapper_pkg = model_data["PRN_CUP_RPM"]

    if cupswrapper_pkg:
        cupswrapper_pkg_version = get_version(cupswrapper_pkg)
        cupswrapper_pkg_url = (
            BROTHER_PKG_BASEURL
            + "/"
            + cupswrapper_pkg.replace(model_name, "${PRINTER_MODEL}").replace(
                "-".join(cupswrapper_pkg_version), "${CUPSWRAPPER_PV}"
            )
        )
    else:
        cupswrapper_pkg_version = None
        cupswrapper_pkg_url = None

    lpd_pkg = model_data["PRN_LPD_RPM"]
    if lpd_pkg == "":
        lpd_pkg = model_data["PRN_DRV_RPM"]
    lpd_pkg_version = get_version(lpd_pkg)
    lpd_pkg_url = (
        BROTHER_PKG_BASEURL
        + "/"
        + lpd_pkg.replace(model_name, "${PRINTER_MODEL}")
        .replace(lpd_pkg_version[0], "${PV}")
        .replace(f"-{lpd_pkg_version[1]}.", "-${RPM_BUILD_NUMBER}.")
    )
    return {
        "name": model_name,
        "commercial_names": {normalize_commercial_name(model_data.name)},
        "cupswrapper_pkg_url": cupswrapper_pkg_url,
        "cupswrapper_pkg_version": cupswrapper_pkg_version,
        "lpd_pkg_url": lpd_pkg_url,
        "lpd_pkg_version": lpd_pkg_version,
    }


def generate_ebuilds():
    config = configparser.ConfigParser()
    config.read(Path("/home/eva/.cache/brother-overlay/infs").glob("*"))

    commercial_names = defaultdict(set)
    for prn_section in config.sections():
        prn_name = normalize_commercial_name(prn_section)
        if "LNK" in config[prn_section]:
            target = config[prn_section]["LNK"]
            commercial_names[target].add(prn_name)
            config.remove_section(prn_section)
        else:
            prn_clean = prn_section.replace("-", "")
            commercial_names[prn_clean].add(prn_name)

    j2env = jinja2.Environment(loader=jinja2.FileSystemLoader("generator"))
    template = j2env.get_template("brother-printer.ebuild.j2")
    root = portage.root
    portdb = portage.db[root]["porttree"].dbapi

    for prn_section in config.sections():
        try:
            tvars = build_template_vars(config[prn_section])
            tvars.update({"commercial_names": sorted(commercial_names[prn_section])})
        except ValueError:
            print("Skipping", model_name, "due to missing data.")
            continue
        ebuild = template.render(tvars)

        # Find latest ebuild
        pkg_name = f"brother-{tvars["name"]}-bin"
        atom = f">=net-print/{pkg_name}-{tvars['lpd_pkg_version'][0]}"
        best_match = portdb.xmatch("bestmatch-visible", atom)
        if best_match:
            version = portage.versions.cpv_getversion(best_match)
            ebuild_fn = f"{pkg_name}-{version}.ebuild"
        else:
            ebuild_fn = f"{pkg_name}-{tvars['lpd_pkg_version'][0]}.ebuild"

        # Write template
        print("Writing", atom)
        (Path("net-print") / pkg_name).mkdir(exist_ok=True)
        (Path("net-print") / pkg_name / ebuild_fn).write_text(ebuild + "\n")


if __name__ == "__main__":
    generate_ebuilds()
