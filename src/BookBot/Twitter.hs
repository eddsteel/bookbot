{-# LANGUAGE OverloadedStrings #-}

module BookBot.Twitter(twPostTxt, twPostImg) where

import BookBot.Data
import Web.Authenticate.OAuth as OA
import Web.Twitter.Conduit
import Web.Twitter.Types (Status)
import qualified Data.ByteString.Char8 as S8
import qualified Data.Text as T

twBuildInfo :: TwitterCredentials -> TWInfo
twBuildInfo creds = setCredential oauth cred def
  where
     oauth = twitterOAuth { oauthConsumerKey = S8.pack $ twConsKey creds
                          , oauthConsumerSecret = S8.pack $ twConsSecret creds }
     cred = Credential [("oauth_token", S8.pack $ twAccsToken creds),
                        ("oauth_token_secret", S8.pack $ twAccsSecret creds)]

twPostTxt :: TwitterCredentials -> Highlight -> IO Status
twPostTxt twitter hl = twPost twitter update
  where
    update = statusesUpdate . T.pack . hlRender $ hl

twPostImg :: TwitterCredentials -> Highlight -> FilePath -> IO Status
twPostImg twitter hl fpath = twPost twitter update
  where
    update = statusesUpdateWithMedia status (MediaFromFile fpath)
    status = T.pack . concat $ ["A quote from ", book hl, " by ", hlAuthor hl, "."]

twPost :: TwitterCredentials -> APIRequest a Status -> IO Status
twPost creds req = do
   mgr <- newManager tlsManagerSettings
   call (twBuildInfo creds) mgr req
