{-# LANGUAGE OverloadedStrings #-}
module Scratch where

import BookBot.Data
import BookBot.Twitter
import BookBot.Soup
import System.Environment
import System.Random

--post :: IO ()
--post = do
--  config <- createConfig getEnv
--  highlights <- parseHighlights
--  res <- postHighlight config (head (tail highlights))
--  print res

main :: IO ()
main = do
  rng <- getStdGen
  highlight <- randomHighlight "resources/single-book-request.html" rng
  putStrLn . hlRender $ highlight
