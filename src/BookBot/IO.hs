module BookBot.IO(bookUrlLocal, listBooksLocal) where
import System.Directory ()
import System.FilePath
import BookBot.Data

listBooksLocal :: Config -> IO [String]
listBooksLocal config = do
  let index = bookUrlLocal config "index.txt"
  contents <- readFile index
  let split = takeWhile (/= ':')
  return $ fmap split (lines contents)

bookUrlLocal :: Config -> String -> String
bookUrlLocal config bk = bookDirectory config </> bk
