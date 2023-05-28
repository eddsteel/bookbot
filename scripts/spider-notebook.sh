#!/usr/bin/env bash
# Log in to read.amazon.com/notebook, and set COOKIE and AMZNDEVTYPE accordingly.

set -ex

[[ -n ${BOOK_DIRECTORY} ]] || { echo 'Set $BOOK_DIRECTORY'; exit 1; }
[[ -n ${MANUAL_DIRECTORY} ]] || { echo 'Set $MANUAL_DIRECTORY'; exit 1; }
[[ -n ${AMZNDEVTYPE} ]] || { echo 'Set $AMZNDEVTYPE'; exit 1; }
[[ -n ${COOKIE} ]] || { echo 'Set $COOKIE'; exit 1; }

mkdir -p $BOOK_DIRECTORY
mkdir -p tmp

get-isbn() {
    grep "$1" manual/ids.csv | cut -f 2 -d,
}

download-books() {
    curl 'https://read.amazon.co.uk/notebook' -s \
         -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0' \
         -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
         -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Connection: keep-alive' \
         -H "Cookie: $COOKIE" \
         -H 'Upgrade-Insecure-Requests: 1' \
         -H 'Sec-Fetch-Dest: document' \
         -H 'Sec-Fetch-Mode: navigate' \
         -H 'Sec-Fetch-Site: none' \
         -H 'Sec-Fetch-User: ?1' \
         -H 'Sec-GPC: 1' \
         -H 'DNT: 1' \
         -o "tmp/notebook"

    grep -Eo 'asin&quot;:&quot;.{10}&quot;' tmp/notebook | cut -c18-27 | while read asin; do
        echo $asin

        curl -s "https://read.amazon.co.uk/notebook?asin=$asin&contentLimitState=&" \
             -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0' \
             -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed \
             -H 'Referer: https://read.amazon.co.uk/notebook' \
             -H 'X-Requested-With: XMLHttpRequest' \
             -H 'Connection: keep-alive' \
             -H "Cookie: $COOKIE" \
             -H 'Sec-Fetch-Dest: empty' \
             -H 'Sec-Fetch-Mode: cors' \
             -H 'Sec-Fetch-Site: same-origin' \
             -H 'Sec-GPC: 1' \
             -H 'DNT: 1' \
             -o "tmp/$asin"
    done
}

convert-books() {
    local isbn
    grep -Eo 'asin&quot;:&quot;.{10}&quot;' tmp/notebook | cut -c18-27 | while read asin; do
        isbn=$(get-isbn "$asin")
        xmllint --encode 'utf-8' --html --xmlout --output "tmp/$asin.xml" "tmp/$asin" && \
        pup -p --charset utf-8 '#highlight text{}' < tmp/$asin.xml | jq -scR \
            --arg asin "$asin" --arg isbn "$isbn" \
            --arg author "$(pup -p --charset utf-8 'div.kp-notebook-annotation-container p.a-spacing-top-micro text{}' < tmp/$asin.xml)" \
            --arg title "$(pup -p --charset utf-8 'div.kp-notebook-annotation-container h3.kp-notebook-selectable text{}' < tmp/$asin.xml)" \
            '{"author": $author, "title": $title, "isbn": $isbn, "asin": $asin, "quotes": split("\n")}' | \
            json2yaml | sed "/- ''/d" \
        > $BOOK_DIRECTORY/$asin.yaml
    done

    # delete empty books
    find tmp -type f -size -20b -delete
    cp -n $MANUAL_DIRECTORY/*.yaml $BOOK_DIRECTORY
    grep -Hc '^- ' $BOOK_DIRECTORY/*.yaml | sed -e "s/$BOOK_DIRECTORY\///" > $BOOK_DIRECTORY/index.txt
}

upload-books() {
    if [[ -n ${S3_BUCKET} ]]; then
        aws s3 sync --delete --content-encoding 'application/yaml; charset=utf-8' \
            $BOOK_DIRECTORY s3://$S3_BUCKET/bookbot/books
        aws s3 cp --content-encoding 'text/plain; charset=utf-8' \
            $BOOK_DIRECTORY/index.txt s3://$S3_BUCKET/bookbot/books/index.txt
    fi
}

#download-books
#convert-books
upload-books
