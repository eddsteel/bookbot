{-# LANGUAGE TemplateHaskell #-}
module BookBot.Data where

import Data.Aeson
import Data.Aeson.TH
import Data.List(isSuffixOf, isPrefixOf, concat, intercalate)
import Data.List.Split
import Data.Monoid
import Text.Regex

data Source = S3 | Local -- | AmazonNotebook ?
            deriving (Show, Eq)

data Highlight = HL {
    book :: String, hlAuthor :: String, quote :: String
  } deriving (Show, Eq)

data BookType = Kindle | Manual
              deriving (Show, Eq)

data ManualBook = MB { title :: String, author :: String, quotes :: [String] }
                deriving (Show, Eq)

deriveJSON defaultOptions ''ManualBook

clean :: Highlight -> Highlight
clean (HL book author quote) = HL book' author' quote'
  where book' = subRegex (mkRegex " \\([^)]*\\)$") book ""
        author' = subRegex (mkRegex ",.*$") author ""
        quote' = subRegex (mkRegex "[”]$")
           (subRegex (mkRegex ".[0-9]+") quote "") ""

hlText :: Highlight -> [String]
hlText hl = [f hl | f <- [book, hlAuthor, quote]]

hlRenderLines :: Highlight -> [String]
hlRenderLines hl = lines ++ [footer]
  where
    lines :: [String]
    lines = fmap (intercalate " ") . chunksOf 9 . words . concat $ ["“", quote hl, "”"]
    footer =  concat [book hl, " — ", hlAuthor hl]

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

bookType :: String -> BookType
bookType url
  | "manual/" `isPrefixOf` url && ".yaml" `isSuffixOf` url = Manual
  | otherwise = Kindle

createConfig :: Applicative f => (String -> f String) -> (String -> f (Maybe String)) -> f Config
createConfig get getM = Config <$>
  get "OAUTH_CONSUMER_KEY" <*>
  get "OAUTH_CONSUMER_SECRET" <*>
  get "OAUTH_ACCESS_TOKEN" <*>
  get "OAUTH_ACCESS_SECRET" <*>
  get "BOOK_DIRECTORY" <*>
  getM "S3_BUCKET" <*>
  getM "S3_URL"
