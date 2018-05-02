#!/bin/sed -f
s:/usr/local/Brother/Printer:/opt/brother/Printers:g
s:/usr/local/Brother/inf:/opt/brother/inf:g
s:\(/etc/printcap\).local:\1:g
