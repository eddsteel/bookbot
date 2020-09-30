{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}
module Scratch where

import BookBot

import BookBot.Data
import BookBot.Image
import BookBot.Twitter
import BookBot.Soup
import BookBot.YAML
import System.Environment
import System.Random
import System.Directory
import Control.Concurrent.PooledIO.Independent

manual :: IO ()
manual = do
  config <- createConfig getEnv lookupEnv
  highlights <- allHighlightsFromFile S3 "http://s3.eddsteel.com.s3-website-us-west-2.amazonaws.com/bookbot/books/manual/black-jacobins.yaml"
  let hl = head highlights
  _ <- postHighlight config hl
  return ()

main :: IO ()
main = manual
