{-# LANGUAGE OverloadedStrings #-}
module BookBot.Twitter(postHighlight,postImg) where

import BookBot.Data
import BookBot.Image
import Data.Maybe (fromMaybe)
import System.Environment
import System.IO (hFlush, stdout)
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

post config req = do
  mgr <- newManager tlsManagerSettings
  call (buildTwInfo config) mgr req


postHighlight :: Config -> Highlight -> IO Status
postHighlight config hl = post config $ statusesUpdate status
  where
    status = T.pack . hlRender $ hl


-- creates an image from the given highlight and posts it.
postImg :: Config -> Highlight -> IO Status
postImg config hl = do
  saveImg (render hl) fpath
  post config $ statusesUpdateWithMedia status (MediaFromFile fpath)
  where
    fpath = "/tmp/bookbot.png"
    status = T.pack . concat $ ["A quote from ", book hl, " by ", hlAuthor hl, "."]
