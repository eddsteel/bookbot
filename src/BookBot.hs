module BookBot(
  module BookBot.Data,
  module BookBot.Init,
  module BookBot.Soup,
  module BookBot.Twitter,
  module BookBot.IO,
  module BookBot.S3,
  pickHighlight) where
import BookBot.Data
import BookBot.Init
import BookBot.Soup
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

pickHighlight :: (RandomGen g) => Config -> g -> IO Highlight
pickHighlight config rng = do
  let src = source config
  books <- listBooks src config
  let url = bookUrl src config $ randomElement rng books
  randomHighlight url rng

