{-# LANGUAGE OverloadedStrings #-}
module BookBot.Twitter(postHighlight,postImg) where

import BookBot.Data
import BookBot.Image
import Data.Maybe (fromMaybe)
import System.Environment
import System.IO (hFlush, stdout)
import Text.HandsomeSoup
import Text.XML.HXT.Core hiding (xshow)
import Text.XML.HXT.DOM.ShowXml
import Web.Authenticate.OAuth as OA
import Web.Twitter.Conduit
import Web.Twitter.Types (Status)
import Network.HTTP.Client.Conduit.Download (download)
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

-- creates an image from the given highlight and posts it.
postImg :: Config -> Highlight -> IO Status
postImg config hl = do
  let twinfo = buildTwInfo config
  saveImg (render hl) "/tmp/bookbot.png"
  mgr <- newManager tlsManagerSettings
  call twinfo mgr $ updateWithMedia "A quote." (MediaFromFile "/tmp/bookbot.png")
  where
    src = source config
