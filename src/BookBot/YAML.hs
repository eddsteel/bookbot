{-# LANGUAGE OverloadedStrings #-}
module BookBot.YAML (allHighlights) where
import BookBot.Data
import Network.HTTP.Simple
import Data.Yaml (decodeEither')
import qualified Data.ByteString.Char8 as B8

byteStringFrom :: Source -> String -> IO B8.ByteString
byteStringFrom (S3 _ _ _) hr = parseRequest hr >>= httpBS >>= return . getResponseBody
byteStringFrom (Local _) fp = B8.readFile fp

allHighlights :: Source -> String -> IO [Highlight]
allHighlights src href = do
  bs <- byteStringFrom src href
  let e = decodeEither' bs
  let bk = case e of
               (Right b) -> b
               (Left _) -> undefined
  return $ HL (title bk) (author bk) `map` quotes bk
