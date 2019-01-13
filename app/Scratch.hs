{-# LANGUAGE OverloadedStrings #-}
module Scratch where

import BookBot

import BookBot.Data
import BookBot.Twitter
import BookBot.Soup
import System.Environment
import System.Random
import System.Directory


main :: IO ()
main = do
  rng <- getStdGen
  config <- createConfig getEnv lookupEnv
  highlight <- pickHighlight config rng
  putStrLn . hlRender $ highlight
