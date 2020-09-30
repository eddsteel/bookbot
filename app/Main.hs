module Main where

import BookBot
import System.Random
import System.IO.Unsafe

main :: IO ()
main = do
  (config, rng) <- initBB
  highlight <- pickHighlight config rng
  res <- if wc highlight >= 280
        then postImg config highlight
        else postHighlight config highlight
  return ()
