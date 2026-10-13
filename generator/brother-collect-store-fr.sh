#!/bin/bash

CACHE_DIR="${XDG_CACHE_DIR:-${HOME}/.cache/brother-overlay/store-fr}"
mkdir -p "${CACHE_DIR}"


page=0
while true
do
	out_file="${CACHE_DIR}/$page.json"
	# User-Agent is mandatory
	curl -v \
		'https://store.brother.fr/coveo/rest/search/v2?sitecoreItemUri=sitecore%3A%2F%2Fweb%2F%7B31E3EE1E-3873-42F3-B90C-342D99EBDCC7%7D%3Flang%3Dfr-FR%26amp%3Bver%3D1&siteName=BrotherFrance' \
		-H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0' \
		-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
		--data-urlencode 'isGuestUser=false' \
		--data-urlencode 'aq=(@ec_category==(2a15d0d7-b04e-d5c0-b7b5-91508c8e02c9,5bdbd412-07ad-1c0f-41be-dcfe7d7431dd,d34eee72-1c70-fc19-4c6b-c25410c17981,2c4c56f0-a590-2d30-45e5-0b4e26697278)) (@lang==fr-FR)' \
		--data-urlencode 'searchHub=printers' \
		--data-urlencode 'maximumAge=900000' \
		--data-urlencode 'wildcards=true' \
		--data-urlencode "firstResult=$((page*100))" \
		--data-urlencode 'locale=fr' \
		--data-urlencode 'numberOfResults=100' \
		--data-urlencode 'excerptLength=200' \
		--data-urlencode 'enableDidYouMean=false' \
		--data-urlencode 'sortCriteria=@ec_price ascending' \
		--data-urlencode 'facets=[{"facetId":"@ec_price","field":"ec_price","type":"numericalRange","injectionDepth":1000,"filterFacetCount":true,"currentValues":[],"numberOfValues":8,"freezeCurrentValues":false,"generateAutomaticRanges":true},{"facetId":"@max_paper_size","field":"max_paper_size","type":"specific","sortCriteria":"score","injectionDepth":1000,"filterFacetCount":true,"currentValues":[],"numberOfValues":8,"freezeCurrentValues":false,"preventAutoSelect":false,"isFieldExpanded":false},{"facetId":"@technology","field":"technology","type":"specific","sortCriteria":"score","injectionDepth":1000,"filterFacetCount":true,"currentValues":[],"numberOfValues":8,"freezeCurrentValues":false,"preventAutoSelect":false,"isFieldExpanded":false},{"facetId":"@printer_function","field":"printer_function","type":"specific","sortCriteria":"score","injectionDepth":1000,"filterFacetCount":true,"currentValues":[],"numberOfValues":8,"freezeCurrentValues":false,"preventAutoSelect":false,"isFieldExpanded":false},{"facetId":"@connectivity","field":"connectivity","type":"specific","sortCriteria":"score","injectionDepth":1000,"filterFacetCount":true,"currentValues":[],"numberOfValues":8,"freezeCurrentValues":false,"preventAutoSelect":false,"isFieldExpanded":false},{"facetId":"@product_category_type_second","field":"product_category_type_second","type":"specific","sortCriteria":"score","injectionDepth":1000,"filterFacetCount":true,"currentValues":[],"numberOfValues":8,"freezeCurrentValues":false,"preventAutoSelect":false,"isFieldExpanded":false}]' \
		--data-urlencode 'retrieveFirstSentences=false' \
		--data-urlencode 'enableQuerySyntax=false' \
		--data-urlencode 'enableDuplicateFiltering=false' \
		--data-urlencode 'enableCollaborativeRating=false' \
		--data-urlencode 'allowQueriesWithoutKeywords=true' \
 		-o "${out_file}"
 	if ! jq --exit-status ".results | length > 0" "${out_file}" > /dev/null; then
		rm "${out_file}"
 		break;
 	fi
 	page=$((page+1))
done

cat "${CACHE_DIR}"/*.json | jq -s -r '.[].results[].raw.isc | select ( endswith("BUNDLE") | not )' | sort > brother-printers-fr.txt
