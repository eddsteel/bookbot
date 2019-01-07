module BookBot.Soup(randomHighlight) where

import BookBot.Data
import Text.XML.HXT.Core hiding (xshow)
import Text.XML.HXT.DOM.ShowXml
import Text.HandsomeSoup
import System.Random

randomHighlight :: RandomGen g => String -> g -> IO Highlight
randomHighlight href rng = do
  all <- allHighlights href
  let (i, _) = randomR (0, length all) rng
  return $ all !! i

allHighlights :: String -> IO [Highlight]
allHighlights href = do
  quotes <- pullQuotesFromBook
  authorText <- xshow . (:[]) <$> pullAuthorFromBook
  bookText <- xshow . (:[]) <$> pullTitleFromBook
  let buildHL = (HL bookText authorText) . xshow . (:[])
  return $ fmap buildHL quotes
  where
    doc = fromUrl href
    pullQuotesFromBook = runX $ doc >>> css "#highlight" >>> deep isText
    pullAuthorFromBook = fmap (head . tail) $ runX $ doc >>> css "div.kp-notebook-annotation-container p.kp-notebook-metadata" >>> deep isText
    pullTitleFromBook = fmap head $ runX $ doc >>> css "div.kp-notebook-annotation-container h3.kp-notebook-selectable" >>> deep isText
