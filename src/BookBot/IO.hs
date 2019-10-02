module BookBot.IO(bookUrlLocal, listBooksLocal) where
import System.Random
import System.Directory
import System.FilePath
import BookBot.Data

listBooksLocal :: Config -> IO [String]
listBooksLocal config =
  let index = bookDirectory config </> "index.txt" in
  fmap lines $ readFile index

bookUrlLocal :: Config -> String -> String
bookUrlLocal config book = bookDirectory config </> book
