# bookbot

Instructions below, and scripts, assume env vars are stored in a file
called `.envrc`. You can use `direnv` to transparently load them.

## Twitter setup

- Create an app [in twitter](https://developer.twitter.com/en/apps) to get API Keys.
- In your environment, set `OAUTH_CONSUMER_KEY` and `OAUTH_CONSUMER_SECRET`.
- Run `bookbot-auth` and follow instructions.
- Set `OAUTH_ACCESS_TOKEN` and `OAUTH_ACCESS_SECRET` accordingly.


## Scrape Amazon notebook

This is currently manual, and requires `wget` and `xmllint`.

- Log into [your notebook](https://read.amazon.com/notebook)
- Use dev tools in the browser, and click on some books, to read your
  current session cookies (store as `COOKIE`) and the value used in
  `amazonDeviceType` parameters (store as `AMZNDEVTYPE`)
- Set `BOOK_DIRECTORY` to configure where book highlights are downloaded to.
- If you specify an `S3_BUCKET` variable, the scraper will upload to it, using `s3cmd`.
- run `scripts/spider-notebook.sh`


## S3

S3 is optional, and controlled by whether `S3_BUCKET` is set. If it
is, the bucket must be public-readable and you must set `S3_URL`
accordingly, such that
`"${S3_URL}/bookbot/${BOOK_DIRECTORY}/index.txt` shows a list of books
when accessed in a browser.


## Post a random highlight to twitter

With the above setup, run `bookbot-post` to choose a random book, and
a random quote from it, and post it to twitter. If `S3_BUCKET` is set,
the book will be retrieved from S3, otherwise the local
`BOOK_DIRECTORY` will be used.
