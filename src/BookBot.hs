module BookBot
  ( module BookBot.Data
  , module BookBot.Init
  , module BookBot.Soup
  , module BookBot.Twitter
  , module BookBot.IO
  , module BookBot.S3
  , pickHighlight
  , randomHighlight
  ) where
import BookBot.Data
import BookBot.Init
import BookBot.Soup
import BookBot.YAML
import BookBot.Twitter
import BookBot.IO
import BookBot.S3
import BookBot.Util
import System.Random

listBooks :: Source -> Config -> IO [String]
listBooks S3 = listBooksS3
listBooks Local = listBooksLocal

bookUrl :: Source -> Config -> String -> String
bookUrl S3 = bookUrlS3
bookUrl Local = bookUrlLocal

allHighlights :: Source -> BookType -> String -> IO [Highlight]
allHighlights _ Kindle = allHighlightsFromSoup
allHighlights src Manual = allHighlightsFromFile src

randomHighlight :: RandomGen g => Source -> BookType -> String -> g -> IO Highlight
randomHighlight src bt href rng = do
  highlights <- allHighlights src bt href
  let (i, _) = randomR (0, length highlights - 1) rng
  return $ highlights !! i

pickHighlight :: RandomGen g => Config -> g -> IO Highlight
pickHighlight config rng = do
  let src = source config
  listing <- listBooks src config
  let books = weighted listing
  let book = randomElement rng books
  let url = bookUrl src config book
  let bt = bookType book
  fmap clean $ randomHighlight src bt url rng
