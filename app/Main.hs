module Main where

import BookBot

main :: IO ()
main = do
  (config, rng) <- initBB
  highlight <- randomHighlight "books/B01BX7S1M2.xml" rng
  res <- postHighlight config highlight
  print res
