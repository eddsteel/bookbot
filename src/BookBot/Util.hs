module BookBot.Util where

import System.Random

randomElement :: (RandomGen) rng => rng -> [a] -> a
randomElement rng elts =
  let (index, _) = randomR (0, length elts - 1) rng
  in elts !! index
