module BookBot.Book(pickHighlight) where

import System.Random
import BookBot.Data
import BookBot.Local
import BookBot.S3
import BookBot.Util
import BookBot.YAML

listBooks :: Source -> IO [String]
listBooks (S3 _ u d) = listBooksS3 u d
listBooks (Local d) = listBooksLocal d

bookUrl :: Source -> String -> String
bookUrl (S3 _ u d) bk = bookUrlS3 u d bk
bookUrl (Local d) bk = bookUrlLocal d bk

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
  let u = bookUrl src bk
  fmap clean $ randomHighlight src u rng
