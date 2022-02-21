{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}
module Scratch where

import BookBot

import BookBot.YAML
import System.Environment

manual :: IO ()
manual = do
  (config, rng) <- initBB
  highlight <- pickHighlight config rng
  putStrLn (show highlight)

singlepost :: IO ()
singlepost = do
  config <- createConfig getEnv lookupEnv
  highlights <- allHighlights S3 "http://s3.eddsteel.com.s3-website-us-west-2.amazonaws.com/bookbot/books/manual/black-jacobins.yaml"
  let hl = head highlights
  _ <- postHighlight config hl
  return ()

singleimg :: IO ()
singleimg = do
  (config, _) <- initBB
  highlights <- allHighlights Local "books/B003100UPG.yaml"
  let hl = highlights !! 1
  _ <- postHighlight config hl
--  _ <- postImg config hl
  putStrLn (show hl)

main :: IO ()
main = singleimg
