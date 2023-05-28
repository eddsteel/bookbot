module Main where

import BookBot

main :: IO ()
main = do
  ((Config src trg), rng) <- initBB
  highlight <- pickHighlight src rng
  _ <- postHighlight trg highlight
  return ()
