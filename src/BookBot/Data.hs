{-# LANGUAGE TemplateHaskell #-}
module BookBot.Data where

import Data.Aeson
import Data.Aeson.TH
import Data.List(intercalate)
import Data.List.Split
import Data.Monoid ()
import Text.Regex

data Source = S3 | Local
            deriving (Show, Eq)

data Highlight = HL {
    book :: String, hlAuthor :: String, quote :: String
  } deriving (Show, Eq)

data Quotes = Q { title :: String, author :: String, quotes :: [String] }
                deriving (Show, Eq)

deriveJSON defaultOptions ''Quotes

clean :: Highlight -> Highlight
clean (HL bk athr qt) = HL book' author' quote'
  where book' = subRegex (mkRegex " \\([^)]*\\)$") bk ""
        author' = subRegex (mkRegex ",.*$") athr ""
        quote' = subRegex (mkRegex "[”]$")
           (subRegex (mkRegex ".[0-9]+") qt "") ""

hlText :: Highlight -> [String]
hlText hl = [f hl | f <- [book, hlAuthor, quote]]

hlRenderLines :: Highlight -> ([String], [String])
hlRenderLines hl = (lns, footer)
  where
    wrap l = fmap (intercalate " ") . chunksOf l . words . concat
    lns    = wrap 8 ["“", quote hl, "”"]
    footer = wrap 6 [book hl, " — ", hlAuthor hl] -- temporary, need to fix fonts

hlRender :: Highlight -> String
hlRender hl = concat ["“", quote hl, "”\n\n", book hl, " — ", hlAuthor hl]

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
