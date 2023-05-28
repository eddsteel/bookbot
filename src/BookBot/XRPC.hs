module BookBot.XRPC(post) where

import Data.Aeson
import Data.Foldable(toList)
import Data.List(intercalate)
import Network.HTTP.Simple
import Network.HTTP.Types.Header (hContentType, hUserAgent, hAuthorization)
import qualified Data.ByteString.Char8 as B

 -- TODO: validate
type NSID = String

headers :: [Header]
headers = [(hContentType, B.pack "application/json"), (hUserAgent, B.pack "BookBot")]

authHeader :: String -> Header
authHeader s = (hAuthorization, B.pack $ "Bearer " ++ s)

post :: (ToJSON a, FromJSON b) => String -> NSID -> a -> Maybe String -> IO (Maybe b)
post url nsid body token = do
  let auth = fmap authHeader . toList $ token
  let allHeaders = headers ++ auth
  request <- parseRequest $ "POST " ++ (intercalate "/" [url, "xrpc", nsid])
  let requestWithBody = setRequestBodyJSON body request
  let requestWithHeaders  = setRequestHeaders allHeaders requestWithBody
  response <- httpLBS requestWithHeaders
  let responseBody = getResponseBody response
  return . decode $ responseBody
