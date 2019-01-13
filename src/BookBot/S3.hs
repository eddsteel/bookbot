module BookBot.S3(bookUrlS3, listBooksS3) where

import BookBot.Data
import Data.Maybe (fromJust)
import Network.HTTP.Simple
import qualified Data.ByteString.Lazy.Char8 as S8

listBooksS3 :: Config -> IO [String]
listBooksS3 config = do
  let url = bookUrlS3 config "index.txt"
  request <- parseRequest url
  response <- httpLBS request
  let body = getResponseBody response
  return . lines . S8.unpack $ body

bookUrlS3 :: Config -> String -> String
bookUrlS3 config book = fromJust (s3Url config) ++ "/bookbot/" ++ bookDirectory config ++ "/" ++ book

