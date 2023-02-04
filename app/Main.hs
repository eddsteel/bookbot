module Main where

import BookBot

main :: IO ()
main = do
  ((Config source target), rng) <- initBB
  highlight <- pickHighlight source rng
  _ <- postHighlight target highlight
  return ()
