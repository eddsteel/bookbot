module BookBot.Util(randomElement, weighted) where

import System.Random
import Data.List.Split

randomElement :: (RandomGen) rng => rng -> [a] -> a
randomElement rng elts =
  let (index, _) = randomR (0, length elts - 1) rng
  in elts !! index

weighted :: [String] -> [String]
weighted = concat . fmap (fill . tk2 . (splitOn ":"))

fill :: (a, Int) -> [a]
fill (w, n) = [w | _ <- [1..n]]

tk2 :: (Num b, Read b) => [String] -> (String, b)
tk2 (a:b:_) = (a, read b)
tk2 (a:[])  = (a, 1)
tk2 _ = ("", 0)
