module BookBot.Data where

data Highlight = HL {book :: String, author :: String, quote :: String}
               deriving (Show, Eq)

wc           :: Highlight -> Int
wc (HL b a q) = length b + length a + length q

