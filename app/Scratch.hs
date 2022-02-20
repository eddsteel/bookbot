{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}
module Scratch where

import BookBot

import BookBot.Image
import BookBot.YAML
import System.Environment

manual :: IO ()
manual = do
  config <- createConfig getEnv lookupEnv
  highlights <- allHighlightsFromFile S3 "http://s3.eddsteel.com.s3-website-us-west-2.amazonaws.com/bookbot/books/manual/black-jacobins.yaml"
  let hl = head highlights
  _ <- postHighlight config hl
  return ()

singleimg :: IO ()
singleimg = do
  highlights <- allHighlightsFromSoup "./B084JSK89X.xml"  
  let highlight = highlights !! 3
  putStrLn (show highlight)
  saveImg (render highlight) "out.png" 

main :: IO ()
main = singleimg
