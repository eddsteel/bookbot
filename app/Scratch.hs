module Scratch where

import BookBot.Data
import Text.XML.HXT.Core hiding (xshow)
import Text.XML.HXT.DOM.ShowXml
import Text.HandsomeSoup


renderHighlight :: Highlight -> String
renderHighlight h = concat [quote h, "(", show (wc h), ")", "\n\n", book h, " — ", author h, "\n\n\n"]

xHighlights doc = runX $ doc >>> css "#highlight" >>> deep isText

xAuthor doc = fmap (head . tail) $ runX $ doc >>> css "div.kp-notebook-annotation-container p.kp-notebook-metadata" >>> deep isText

xBook doc = fmap head $ runX $ doc >>> css "div.kp-notebook-annotation-container h3.kp-notebook-selectable" >>> deep isText

main :: IO ()
main = do
  let doc = fromUrl "resources/single-book-request.html"
  highlights <- xHighlights doc
  author <- xshow . (:[]) <$> xAuthor doc
  book <-  xshow . (:[]) <$> xBook doc
  let buildHL = renderHighlight . (HL book author) . xshow . (:[])
  let quotes = fmap buildHL highlights
  mapM_ putStrLn quotes
