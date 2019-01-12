module BookBot(
  module BookBot.Data,
  module BookBot.Init,
  module BookBot.Soup,
  module BookBot.Twitter,
  module BookBot.IO,
  pickHighlight) where
import BookBot.Data
import BookBot.Init
import BookBot.Soup
import BookBot.Twitter
import BookBot.IO
import System.Random

pickHighlight :: (RandomGen g) => Config -> g -> IO Highlight
pickHighlight config rng = do
  let bookDir = (bookDirectory config)
  book <- randomBook rng bookDir
  randomHighlight book rng

