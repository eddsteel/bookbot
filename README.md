# bookbot

Instructions below, and scripts, assume env vars are stored in a file
called `.envrc`. You can use `direnv` to transparently load them.


## Twitter setup

- Create an app [in twitter](https://developer.twitter.com/en/apps) to get API Keys.
- In your environment, set `OAUTH_CONSUMER_KEY` and `OAUTH_CONSUMER_SECRET`.
- Run `bookbot-auth` and follow instructions.
- Set `OAUTH_ACCESS_TOKEN` and `OAUTH_ACCESS_SECRET` accordingly.


## Add quotes manually

The bookbot reads quotes from YAML files. See [./manual/black-jacobins.yaml](black-jacobins.yaml) for the format. You should set `$MANUAL_DIRECTORY` to the directory containing these yaml files.


## Scrape Amazon notebook

 You can also generate YAML files from your Kindle notebook. This is currently manual, and requires `curl`, `xmllint`, `pup`, `jq`, `json2yaml` (`nix-shell` will give you them).

- Log into [your notebook](https://read.amazon.com/notebook)
- Use dev tools in the browser, and click on some books, to read your
  current session cookies (store as `COOKIE`).
- Set `BOOK_DIRECTORY` to configure where book highlights are downloaded to.
- If you specify an `S3_BUCKET` variable, the scraper will upload to it, using `aws s3`.
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

## Docker

The included Dockerfile specifies a container that runs
`bookbot-post`. You can run `make image` to buid it. You can run `make
deploy` to both build it and push to your ECR repository (using `aws
ecr`). You can then deploy that with appropriate environment for adhoc
fargate tasks or on a schedule. This is how
[@eddbookbot](https://twitter.com/eddbookbot) runs.


# TODO

- Add ISBN and publish date from https://www.amazon.com/exec/obidos/ASIN/{ASIN}
- Add date and link to abebooks with ISBN to the tweets.
  https://www.abebooks.com/servlet/SearchResults?sts=t&kn={ISBN}
- (outside of this project) push all quotes up to literal.club.
