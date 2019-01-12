{-# LANGUAGE OverloadedStrings #-}
module Scratch where

import BookBot.Data
import BookBot.Twitter
import BookBot.Soup
import System.Environment
import System.Random
import System.Directory

randomBook :: (RandomGen) rng => rng -> FilePath -> IO FilePath
randomBook rng dir = do
  books <- listDirectory dir
  let (index, _) = randomR (0, length books) rng
  return $ concat [dir, "/", books !! index]


--post :: IO ()
--post = do
--  config <- createConfig getEnv
--  highlights <- parseHighlights
--  res <- postHighlight config (head (tail highlights))
--  print res

main :: IO ()
main = do
  rng <- getStdGen
  file <- randomBook rng "books"
  highlight <- randomHighlight file rng
  putStrLn . hlRender $ highlight
