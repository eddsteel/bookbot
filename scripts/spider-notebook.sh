#!/bin/bash
# Log in to read.amazon.com/notebook, and set COOKIE and AMZNDEVTYPE accordingly.
. .env

[[ -n ${BOOK_DIRECTORY} ]] || { echo 'Set $BOOK_DIRECTORY'; exit 1; }
[[ -n ${AMZNDEVTYPE} ]] || { echo 'Set $AMZNDEVTYPE'; exit 1; }
[[ -n ${COOKIE} ]] || { echo 'Set $COOKIE'; exit 1; }

mkdir -p $BOOK_DIRECTORY
mkdir -p tmp

wget -O tmp/notebook --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0' --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.5' --header 'DNT: 1' --header 'Connection: keep-alive' --header "Cookie: $COOKIE" https://read.amazon.com/notebook

grep -Eo 'asin&quot;:&quot;.{10}&quot;' tmp/notebook | cut -c18-27 | while read asin; do
    wget -O "$BOOK_DIRECTORY/$asin" \
         --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0' \
         --header 'Accept: */*' \
         --header 'Accept-Language: en-US,en;q=0.5' \
         --header 'DNT: 1' \
         --header 'Connection: keep-alive' \
         --header "Cookie: $COOKIE" \
         "https://read.amazon.com/notebook?amazonDeviceType=$AMZNDEVTYPE&asin=$asin&contentLimitState=&"
    xmllint -html -xmlout "$BOOK_DIRECTORY/$asin" > "$BOOK_DIRECTORY/$asin.xml" && \
        rm "$BOOK_DIRECTORY/$asin"
    sleep 1
done

# delete empty books
find $BOOK_DIRECTORY -type f -size -20b -delete
