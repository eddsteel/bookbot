{-# LANGUAGE OverloadedStrings, FlexibleContexts #-}
module Auth where

import Data.Maybe (fromMaybe)
import System.Environment
import System.IO (hFlush, stdout)
import Web.Authenticate.OAuth as OA
import Web.Twitter.Conduit hiding (lookup)
import qualified Data.ByteString.Char8 as S8

dumpCreds :: OAuth -> Credential -> IO ()
dumpCreds oauth (Credential cred) =
  S8.putStrLn . S8.concat $
  [ "export OAUTH_CONSUMER_KEY=\"", oauthConsumerKey oauth, "\"\n"
  , "export OAUTH_CONSUMER_SECRET=\"", oauthConsumerSecret oauth, "\"\n"
  , "export OAUTH_ACCESS_TOKEN=\"", fromMaybe "" (lookup "oauth_token" cred), "\"\n"
  , "export OAUTH_ACCESS_SECRET=\"", fromMaybe "" (lookup "oauth_token_secret" cred), "\"\n"]

authenticate :: OAuth -> IO Credential
authenticate oauth = do
  mgr <- newManager tlsManagerSettings
  cred <- OA.getTemporaryCredential oauth mgr
  let url = OA.authorizeUrl oauth cred
  pin <- getPIN url
  let verifier = OA.insert "oauth_verifier" pin cred
  OA.getAccessToken oauth verifier mgr
  where
    getPIN :: String -> IO S8.ByteString
    getPIN url = do
      putStrLn $ "browse URL: " ++ url
      putStr "Enter PIN"
      hFlush stdout
      S8.getLine

buildTokens :: IO OAuth
buildTokens = do
  consumerKey <- getEnv "OAUTH_CONSUMER_KEY"
  consumerSecret <- getEnv "OAUTH_CONSUMER_SECRET"
  return $
    twitterOAuth
    { oauthConsumerKey = S8.pack consumerKey
    , oauthConsumerSecret = S8.pack consumerSecret
    , oauthCallback = Just "oob"
    }

main :: IO ()
main = do
  oauth <- buildTokens
  creds <- authenticate oauth
  dumpCreds oauth creds
