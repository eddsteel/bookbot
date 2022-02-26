{-# LANGUAGE OverloadedStrings #-}
module BookBot.YAML (allHighlights) where
import BookBot.Data
import Network.HTTP.Simple
import Data.Yaml (decodeEither')
import qualified Data.ByteString.Char8 as B8

byteStringFromUri :: String -> IO B8.ByteString
byteStringFromUri uri = do
  parseRequest uri >>= httpBS >>= return . getResponseBody

byteStringFromFile :: FilePath -> IO B8.ByteString
byteStringFromFile = B8.readFile

byteStringFrom :: Source -> String -> IO B8.ByteString
byteStringFrom S3 uri = byteStringFromUri uri
byteStringFrom Local fp = byteStringFromFile fp

allHighlights :: Source -> String -> IO [Highlight]
allHighlights src href = do
  bs <- byteStringFrom src href
  let e = decodeEither' bs
  let (Right bk) = e -- lol this sucks
  return $ HL (title bk) (author bk) `map` quotes bk
