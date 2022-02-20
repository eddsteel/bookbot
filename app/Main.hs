module Main where

import BookBot

main :: IO ()
main = do
  (config, rng) <- initBB
  highlight <- pickHighlight config rng
  _ <- if wc highlight >= 280
       then postImg config highlight
       else postHighlight config highlight
  return ()
