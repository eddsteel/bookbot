module BookBot.S3(bookUrlS3, listBooksS3) where

import BookBot.Data
import Data.Maybe (fromJust)
import Network.HTTP.Simple
import qualified Data.ByteString.Lazy.Char8 as S8

getListingS3 :: String -> IO [String]
getListingS3 url = do
    request <- parseRequest url
    response <- httpLBS request
    let body = getResponseBody response
    return . lines . S8.unpack $ body

listBooksS3 :: Config -> IO [String]
listBooksS3 config =
  getListingS3 $ bookUrlS3 config "index.txt"
  
bookUrlS3 :: Config -> String -> String
bookUrlS3 config bk = fromJust (s3Url config) ++ "/bookbot/" ++ bookDirectory config ++ "/" ++ bk

