module BookBot.Book(pickHighlight) where

import System.Random
import BookBot.Data

listBooks :: Source -> IO [String]
listBooks (S3 _ url _) = listBooksS3 url
listBooks (Local dir) = listBooksLocal dir

bookUrl :: Source -> String -> String
bookUrl (S3 _ url dir) bk = bookUrlS3 url dir bk
bookUrl (Local dir) bk = bookUrlLocal dir bk

randomHighlight :: RandomGen g => Source -> String -> g -> IO Highlight
randomHighlight src href rng = do
  highlights <- allHighlights src href
  let (i, _) = randomR (0, length highlights - 1) rng
  return $ highlights !! i

pickHighlight :: RandomGen g => Source -> g -> IO Highlight
pickHighlight src rng = do
  listing <- listBooks src
  let books = weighted listing
  let bk = randomElement rng books
  let url = bookUrl src bk
  fmap clean $ randomHighlight src url rng
