{-# LANGUAGE OverloadedStrings #-}
module BookBot.YAML (allHighlightsFromFile) where
import BookBot.Data
import Network.HTTP.Simple
import Data.Yaml (decodeEither, ParseException)
import qualified Text.URI as URI
import qualified Data.ByteString.Char8 as B8

byteStringFromUri :: String -> IO B8.ByteString
byteStringFromUri uri = do
  parseRequest uri >>= httpBS >>= return . getResponseBody

byteStringFromFile :: FilePath -> IO B8.ByteString
byteStringFromFile = B8.readFile

byteStringFrom :: Source -> String -> IO B8.ByteString
byteStringFrom S3 uri = byteStringFromUri uri
byteStringFrom Local fp = byteStringFromFile fp

allHighlightsFromFile :: Source -> String -> IO [Highlight]
allHighlightsFromFile src href = do
  bs <- byteStringFrom src href
  let either = decodeEither bs
  let (Right book) = either -- lol this sucks
  return $ HL (title book) (author book) `map` quotes book
