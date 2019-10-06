#!/bin/bash
# Log in to read.amazon.com/notebook, and set COOKIE and AMZNDEVTYPE accordingly.
if [ -f .envrc ]; then . .envrc; fi

[[ -n ${BOOK_DIRECTORY} ]] || { echo 'Set $BOOK_DIRECTORY'; exit 1; }
[[ -n ${AMZNDEVTYPE} ]] || { echo 'Set $AMZNDEVTYPE'; exit 1; }
[[ -n ${COOKIE} ]] || { echo 'Set $COOKIE'; exit 1; }

mkdir -p $BOOK_DIRECTORY
mkdir -p tmp

ua='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0'

wget --quiet --output-document tmp/notebook \
     --header "$ua" \
     --header 'Accept: */*' \
     --header 'Accept-Language: en-US,en;q=0.5' \
     --header 'DNT: 1' \
     --header 'Connection: keep-alive' \
     --header "Cookie: $COOKIE" \
     https://read.amazon.com/notebook

grep -Eo 'asin&quot;:&quot;.{10}&quot;' tmp/notebook | cut -c18-27 | while read asin; do
    echo $asin
    wget --quiet --output-document "$BOOK_DIRECTORY/$asin" \
         --header "$ua" \
         --header 'Accept: */*' \
         --header 'Accept-Language: en-US,en;q=0.5' \
         --header 'DNT: 1' \
         --header 'Connection: keep-alive' \
         --header "Cookie: $COOKIE" \
         "https://read.amazon.com/notebook?amazonDeviceType=$AMZNDEVTYPE&asin=$asin&contentLimitState=&"
done

grep -Eo 'asin&quot;:&quot;.{10}&quot;' tmp/notebook | cut -c18-27 | while read asin; do
    xmllint --encode 'utf-8' --html --xmlout  --output "$BOOK_DIRECTORY/$asin.xml" \
        "$BOOK_DIRECTORY/$asin" && \
        rm "$BOOK_DIRECTORY/$asin"
done

# delete empty books
find $BOOK_DIRECTORY -type f -size -20b -delete

# generate listing: file:n
grep -c "a-row kp-notebook-highlight kp-notebook-selectable kp-notebook-highlight-yellow" \
     $BOOK_DIRECTORY/*.xml | sed -e "s/$BOOK_DIRECTORY\///" > $BOOK_DIRECTORY/index.txt

if [[ -n ${S3_BUCKET} ]]; then
    aws s3 sync --delete --content-encoding 'text/xml; charset=utf-8' \
          $BOOK_DIRECTORY s3://$S3_BUCKET/bookbot/books
fi
