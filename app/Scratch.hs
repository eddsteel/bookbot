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
  highlight <- randomHighlight "books/B01BX7S1M2.xml" rng
  putStrLn . hlRender $ highlight
