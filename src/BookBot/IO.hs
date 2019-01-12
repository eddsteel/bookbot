module BookBot.IO(randomBook) where
import System.Random
import System.Directory

randomBook :: (RandomGen g) => g -> FilePath -> IO FilePath
randomBook rng dir = do
  books <- listDirectory dir
  let (index, _) = randomR (0, length books - 1) rng
  return $ concat [dir, "/", books !! index]

       
