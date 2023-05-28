{-# LANGUAGE OverloadedStrings #-}

module BookBot.Post(postHighlight, postTxt, postImg) where

import BookBot.Data
import BookBot.Image
import BookBot.Twitter
import BookBot.BlueSky
import Data.Text

postHighlight :: Target -> Highlight -> IO Text
postHighlight t hl = let fpath = "/tmp/bookbot.png" in
  if shouldPostImg t hl
  then do
    saveImg (render hl) fpath
    postImg t hl fpath
  else postTxt t hl

shouldPostImg :: Target -> Highlight -> Bool
shouldPostImg (Twitter {}) hl = wc hl >= 280
shouldPostImg (BlueSky {}) hl = wc hl >= 300
shouldPostImg Console _ = False
shouldPostImg (ActivityPub {}) _ = False

postTxt :: Target -> Highlight -> IO Text
postTxt (Twitter t) hl      = twPostTxt t hl >> return "OK"
postTxt Console hl          = putStrLn (show hl) >> return "OK"
postTxt (ActivityPub {}) hl = putStrLn (show hl) >> return "OK"
postTxt (BlueSky b) hl      = bsPostTxt b hl >> return "OK"

postImg :: Target -> Highlight -> FilePath -> IO Text
postImg (Twitter t) hl fp     = twPostImg t hl fp >> return "OK"
postImg Console hl _          = putStrLn (show hl) >> return "OK"
postImg (ActivityPub {}) hl _ = putStrLn (show hl) >> return "OK"
postImg (BlueSky {}) hl _     = putStrLn (show hl) >> return "OK"
