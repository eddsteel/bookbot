module BookBot.BlueSky(bsPostTxt) where

import BookBot.Data
import BookBot.XRPC
import Data.Aeson
import Data.Maybe(fromJust)
import Data.Time(getCurrentTime)
import Data.Time.Format(defaultTimeLocale, formatTime)

textPost :: String -> String -> IO BlueSkyCreateRecord
textPost rep txt = fmap (\n -> CR rep "app.bsky.feed.post" $ TP txt n) now
  where now = do
          t <- getCurrentTime
          let s = take 23 . formatTime defaultTimeLocale "%FT%T%Q" $ t
          return $ s ++ "Z"

createSession :: BlueSkyCredentials -> IO BlueSkySession
createSession (BC idr token) = do
  let body = LR idr token
  resp <- post "https://bsky.social" "com.atproto.server.createSession" body Nothing
  return $ fromJust resp

bsPostTxt :: BlueSkyCredentials -> Highlight -> IO ()
bsPostTxt credentials hl  = do
  session <- createSession credentials
  body <- textPost (did session) (hlRender hl)
  _ <- post "https://bsky.social" "com.atproto.repo.createRecord" body (Just $ accessJwt session) :: IO (Maybe Value)
  return ()
