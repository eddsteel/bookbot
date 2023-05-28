module BookBot.Local(bookUrlLocal, listBooksLocal) where
import System.Directory ()
import System.FilePath

listBooksLocal :: FilePath -> IO [String]
listBooksLocal dir = do
  let index = dir </> "index.txt"
  contents <- readFile index
  let split = takeWhile (/= ':')
  return $ fmap split (lines contents)

bookUrlLocal :: String -> String -> String
bookUrlLocal dir bk = dir </> bk
