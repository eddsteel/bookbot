module Main where

import BookBot

main :: IO ()
main = do
  (config, rng) <- initBB
  highlight <- randomHighlight "resources/single-book-request.html" rng
  res <- postHighlight config highlight
  print res
