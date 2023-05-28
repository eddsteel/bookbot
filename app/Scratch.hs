{-# LANGUAGE OverloadedStrings         #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}
module Scratch where

import BookBot
import BookBot.YAML

manual :: IO ()
manual = do
  ((Config src trg), rng) <- initBB
  highlight <- pickHighlight src rng  
--  _ <- postImg trg highlight "/tmp/foo.png"
  _ <- postHighlight trg highlight
  return ()

singlepost :: IO ()
singlepost = do
  ((Config src trg), _) <- initBB
  highlights <- allHighlights src "http://s3.eddsteel.com.s3-website-us-west-2.amazonaws.com/bookbot/books/manual/black-jacobins.yaml"
  let hl = head highlights
  _ <- postHighlight trg hl
  return ()

singleimg :: IO ()
singleimg = do
  ((Config _ trg), _) <- initBB
  highlights <- allHighlights (Local "books") "books/B003100UPG.yaml"
  let hl = highlights !! 1
  _ <- postHighlight trg hl
-- _ <- postImg trg hl "/tmp/foo.png"
  putStrLn (show hl)

checkS3 :: IO ()
checkS3 = do
  ((Config src _), _) <- initBB
  -- highlight <- pickHighlight src rng
  highlights <- allHighlights src "https://s3.eddsteel.com/bookbot/books/manual/black-jacobins.yaml"  
  _ <- postHighlight Console $ highlights !! 1
  return ()

main :: IO ()
main = manual
