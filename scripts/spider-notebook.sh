#!/bin/bash
# Log in to read.amazon.com/notebook, and set COOKIE and AMZNDEVTYPE accordingly.
. .env

mkdir -p books
mkdir -p tmp

wget -O tmp/notebook --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0' --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.5' --header 'DNT: 1' --header 'Connection: keep-alive' --header "Cookie: $COOKIE" https://read.amazon.com/notebook

grep -Eo 'asin&quot;:&quot;.{10}&quot;' tmp/notebook | cut -c18-27 | while read asin; do
    wget -O books/$asin --header 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0' --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.5' --header 'DNT: 1' --header 'Connection: keep-alive' --header "Cookie: $COOKIE" "https://read.amazon.com/notebook?amazonDeviceType=$AMZNDEVTYPE&asin=$asin&contentLimitState=&"
    xmllint -html -xmlout books/$asin > books/$asin.xml && rm books/$asin
    sleep 1
done

find books -type f -size -20b -delete
