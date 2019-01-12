module Main where

import BookBot
import System.Random
import System.IO.Unsafe

main :: IO ()
main = do
  (config, rng) <- initBB
  let rans = take 5 $ rngs rng
  highlights <- traverse (pickHighlight config) rans
  let highlight = head $ dropWhile tooLong highlights
  res <- postHighlight config highlight
  print res
  where
    tooLong hl = wc hl >= 280
    rngs = iterate (snd . next)
