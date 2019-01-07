{-# LANGUAGE OverloadedStrings #-}
module BookBot.Twitter(postHighlight) where

import BookBot.Data
import Data.Maybe (fromMaybe)
import System.Environment
import System.IO (hFlush, stdout)
import Text.HandsomeSoup
import Text.XML.HXT.Core hiding (xshow)
import Text.XML.HXT.DOM.ShowXml
import Web.Authenticate.OAuth as OA
import Web.Twitter.Conduit
import Web.Twitter.Types (Status)
import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as T

buildTwInfo :: Config -> TWInfo
buildTwInfo config = setCredential oauth cred def
  where
    oauth = twitterOAuth { oauthConsumerKey = S8.pack $ consumerKey config
                         , oauthConsumerSecret = S8.pack $ consumerSecret config}
    cred = Credential [("oauth_token", S8.pack $ accessToken config),
                       ("oauth_token_secret", S8.pack $ accessSecret config)]

postHighlight :: Config -> Highlight -> IO Status
postHighlight config hl = do
  let twinfo = buildTwInfo config
  let status = T.pack . hlRender $ hl
  mgr <- newManager tlsManagerSettings
  call twinfo mgr $ update status
