module BookBot.S3(bookUrlS3, listBooksS3) where

import Data.List (intercalate)
import Network.HTTP.Simple
import qualified Data.ByteString.Lazy.Char8 as S8

listBooksS3 :: String -> IO [String]
listBooksS3 rootURL = do
    request <- parseRequest (rootURL ++ "/index.txt")
    response <- httpLBS request
    let body = getResponseBody response
    return . lines . S8.unpack $ body

bookUrlS3 :: String -> String -> String -> String
bookUrlS3 s3URL dir bk = intercalate "/" [s3URL, "bookbot", dir, bk]
