# bookbot

Instructions below, and scripts,  assume env vars are stored in a file called `.env`.

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
- run `scripts/spider-notebook.sh`
