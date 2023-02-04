{-# LANGUAGE OverloadedStrings #-}

module BookBot.Post(postHighlight, postTxt, postImg) where

import BookBot.Data
import BookBot.Image
import BookBot.Twitter
import Data.Text

postHighlight :: Target -> Highlight -> IO Text
postHighlight target hl = renderStatus <$> s
  where
    fpath = "/tmp/bookbot.png"
    s = if shouldPostImg target highlight
        then postTxt target hl
        else do
          saveImg (render hl) fpath
          postImg t hl fpath

shouldPostImg :: Target -> Highlight -> Bool
shouldPostImg (Twitter {}) hl = wc hl <= 280
shouldPostImg Console _ = False
shouldPostImg (APub {}) _ = False

postTxt :: Target -> Highlight -> IO Text
postTxt t@(Twitter {}) = twPostTxt t >> return "OK"
postTxt Console hl = show hl >>= putStrLn
postTxt (APub {}) = show hl >>= putStrLn

postImg :: Target -> Highlight -> Path -> IO Text
postImg t@(Twitter {}) = twPostImg t >> return "OK"
postImg Console hl _ = show hl >>= putStrLn
postImg (Apub {}) = show hl >>= putStrLn
