{-# LANGUAGE TemplateHaskell #-}
module BookBot.Data where

import Data.Aeson
import Data.Aeson.TH
import Data.List(intercalate)
import Data.List.Split
import Data.Monoid ()
import Text.Regex

-- TODO: actual URL
data Source = S3 { bucket :: String, url :: String, bookDir :: String } | Local { bookDir :: String }
            deriving (Show, Eq)

data TwitterCredentials = TC { twConsKey :: String, twConsSecret :: String,
                        twAccsToken :: String, twAccsSecret :: String } deriving (Show, Eq)
data ActivityPubCredentials = AC { apToken :: String, apID :: String, apSecret :: String } deriving (Show, Eq)
data BlueSkyCredentials = BC { bsIdentifier :: String, bsAppToken :: String } deriving (Show, Eq)
data Target = Twitter TwitterCredentials
            | ActivityPub ActivityPubCredentials
            | BlueSky BlueSkyCredentials
            | Console
            deriving (Show, Eq)

data Highlight = HL {
    book :: String, hlAuthor :: String, quote :: String
  } deriving (Show, Eq)

data Quotes = Q { title :: String, author :: String, quotes :: [String] }
                deriving (Show, Eq)

deriveJSON defaultOptions ''Quotes


-- Bluesky IO JSON
type Identifier = String
type AppToken = String

data BlueSkyCreateRecord = CR { repo :: String, collection :: String, record :: BlueSkyTextPost } deriving (Show, Eq)
data BlueSkyTextPost = TP { text :: String, createdAt :: String } deriving (Show, Eq)
data BlueSkyLoginRequest = LR { identifier :: Identifier, password :: AppToken } deriving (Show, Eq)
data BlueSkySession = BS { did :: String, accessJwt :: String } deriving (Show, Eq)

deriveJSON defaultOptions ''BlueSkyTextPost
deriveJSON defaultOptions ''BlueSkyCreateRecord
deriveJSON defaultOptions ''BlueSkyLoginRequest
deriveJSON defaultOptions ''BlueSkySession


clean :: Highlight -> Highlight
clean (HL bk athr qt) = HL book' author' quote'
  where book' = subRegex (mkRegex " \\([^)]*\\)$") bk ""
        author' = subRegex (mkRegex ",.*$") athr ""
        quote' = subRegex (mkRegex "[”]$")
           (subRegex (mkRegex ".[0-9]+") qt "") ""

hlText :: Highlight -> [String]
hlText hl = [f hl | f <- [book, hlAuthor, quote]]

hlRenderLines :: Highlight -> ([String], [String])
hlRenderLines hl = (lns, footer)
  where
    wrap l = fmap (intercalate " ") . chunksOf l . words . concat
    lns    = wrap 8 ["“", quote hl, "”"]
    footer = wrap 6 [book hl, " — ", hlAuthor hl] -- temporary, need to fix fonts

hlRender :: Highlight -> String
hlRender hl = concat ["“", quote hl, "”\n\n", book hl, " — ", hlAuthor hl]

data EnvConfig = EnvConfig {
              twitterConsumerKey :: Maybe String,
              twitterConsumerSecret :: Maybe String,
              twitterAccessToken :: Maybe String,
              twitterAccessSecret :: Maybe String,
              bookDirectory :: FilePath,
              s3Bucket :: Maybe String,
              s3Url :: Maybe String,
              aPubAccessToken :: Maybe String,
              aPubClientID :: Maybe String,
              aPubClientSecret :: Maybe String,
              bSkyIdentifier :: Maybe String,
              bSkyAppToken :: Maybe String
}

data Config = Config {
   source :: Source,
   target :: Target
}

config :: EnvConfig -> Config
config ec = Config (configSource ec) (configTarget ec)

configSource :: EnvConfig -> Source
configSource c = case sequence [s3Bucket c, s3Url c] of
  Just [s3b, s3u] -> S3 s3b s3u (bookDirectory c)
  _ -> Local (bookDirectory c)

configTarget :: EnvConfig -> Target
configTarget c = case sequence [aPubAccessToken c, aPubClientID c, aPubClientSecret c] of
    Just [tok, cid, sec] -> ActivityPub (AC tok cid sec)
    _ -> case sequence [ bSkyIdentifier c, bSkyAppToken c ] of
        Just [bid, atk] -> BlueSky (BC bid atk)
        _ -> case sequence [twitterConsumerKey c, twitterConsumerSecret c,
                            twitterAccessToken c, twitterAccessSecret c] of
            Just [cKey, cSec, aTok, aSec ] -> Twitter (TC cKey cSec aTok aSec)
            _ -> Console

wc :: Highlight -> Int
wc = length . hlRender

createConfig :: Applicative f => (String -> f String) -> (String -> f (Maybe String)) -> f EnvConfig
createConfig get getM = EnvConfig <$>
  getM "OAUTH_CONSUMER_KEY" <*>
  getM "OAUTH_CONSUMER_SECRET" <*>
  getM "OAUTH_ACCESS_TOKEN" <*>
  getM "OAUTH_ACCESS_SECRET" <*>
  get "BOOK_DIRECTORY" <*>
  getM "S3_BUCKET" <*>
  getM "S3_URL" <*>
  getM "APUB_ACCESS_TOKEN" <*>
  getM "APUB_CLIENT_ID" <*>
  getM "APUB_CLIENT_SECRET" <*>
  getM "BSKY_IDENTIFIER" <*>
  getM "BSKY_APP_TOKEN"
