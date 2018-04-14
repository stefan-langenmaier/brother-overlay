#!/bin/sed -f
/^cat <<!ENDOFWFILTER!/,/^!ENDOFWFILTER!/!d
/!ENDOFWFILTER!/d
s/\\\([\`$]\)/\1/g
