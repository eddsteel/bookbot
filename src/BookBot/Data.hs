module BookBot.Data where

import Data.Monoid

data Highlight = HL { book :: String, author :: String, quote :: String }
               deriving (Show, Eq)

hlText :: Highlight -> [String]
hlText hl = [f hl | f <- [book, author, quote]]

hlRender :: Highlight -> String
hlRender hl = concat ["“", quote hl, "”\n\n", book hl, " — ", author hl]

data Config = Config {
              consumerKey :: String,
              consumerSecret :: String,
              accessToken :: String,
              accessSecret :: String,
              bookDirectory :: FilePath
              }

wc :: Highlight -> Int
wc = length . hlRender

createConfig :: Applicative f => (String -> f String) -> f Config
createConfig get = Config <$>
  get "OAUTH_CONSUMER_KEY" <*>
  get "OAUTH_CONSUMER_SECRET" <*>
  get "OAUTH_ACCESS_TOKEN" <*>
  get "OAUTH_ACCESS_SECRET" <*>
  get "BOOK_DIRECTORY"
