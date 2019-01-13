module BookBot.IO(bookUrlLocal, listBooksLocal) where
import System.Random
import System.Directory
import System.FilePath
import BookBot.Data

listBooksLocal :: Config -> IO [String]
listBooksLocal = listDirectory . bookDirectory

bookUrlLocal :: Config -> String -> String
bookUrlLocal config book = bookDirectory config </> book
