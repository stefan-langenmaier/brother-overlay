#!/bin/bash
#
# Go to https://www.brother-usa.com/c/shop/printers and extra Authorization header value

CACHE_DIR="${XDG_CACHE_DIR:-${HOME}/.cache/brother-overlay/store-usa}"
mkdir -p "${CACHE_DIR}"

BEARER_TOKEN=$1

page=0
while true
do
	out_file="${CACHE_DIR}/$page.json"
	curl \
		-H "Authorization: ${BEARER_TOKEN}" \
		"https://www.brother-usa.com/mobify/proxy/api/search/shopper-search/v1/organizations/f_ecom_blqs_prd/product-search?siteId=BrotherUSA&refine=cgid%3Dprinters&sort=best-matches&currency=USD&locale=en-US&expand=promotions%2Cvariations%2Cprices%2Cimages%2Cpage_meta_tags%2Ccustom_properties%2Cavailability&allImages=true&perPricebook=true&allVariationProperties=true&&offset=$((page*100))&limit=100" \
		-o "${out_file}"
	if ! jq --exit-status ".hits" "${out_file}" > /dev/null; then
		rm "${out_file}"
		break;
	fi
	page=$((page+1))
done

cat "${CACHE_DIR}"/*.json | jq -s -r '.[].hits[].representedProduct | select(
	.c_productConsumableType and
	.c_productIsBrotherBundle == false and
	.c_productCondition != "Refurbished"
) | .id' | sort > brother-printers-usa.txt
