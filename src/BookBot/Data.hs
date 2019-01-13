module BookBot.Data where

import Data.Monoid

data Source = S3 | Local -- | AmazonNotebook ?
            deriving (Show, Eq)

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
              bookDirectory :: FilePath,
              s3Bucket :: Maybe String,
              s3Url :: Maybe String
              }

source :: Config -> Source
source c = case (s3Bucket c) of
  Just _ -> S3
  Nothing -> Local

wc :: Highlight -> Int
wc = length . hlRender

createConfig :: Applicative f => (String -> f String) -> (String -> f (Maybe String)) -> f Config
createConfig get getM = Config <$>
  get "OAUTH_CONSUMER_KEY" <*>
  get "OAUTH_CONSUMER_SECRET" <*>
  get "OAUTH_ACCESS_TOKEN" <*>
  get "OAUTH_ACCESS_SECRET" <*>
  get "BOOK_DIRECTORY" <*>
  getM "S3_BUCKET" <*>
  getM "S3_URL"
