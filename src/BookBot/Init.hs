module BookBot.Init(initBB) where

import BookBot.Data
import System.Environment
import System.Random

initBB :: IO (Config, StdGen)
initBB = (,) <$> (config <$> createConfig getEnv lookupEnv) <*> getStdGen
