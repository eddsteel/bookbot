import BookBot.Data
import Test.Hspec

rawHighlight = HL "The Three-Body Problem (Remembrance of Earth's Past Book 1)"
                  "Cixin Liu and Ken Liu"
                  "Keep your phone on, buddy. Keep your head screwed on straight, and if you get scared again, just remember my ultimate rule.”" 

main :: IO ()
main = hspec $ do
  describe "Highlight" $ do
    it "cleans data as expected" $ do
      book (clean rawHighlight) `shouldBe` "The Three-Body Problem"
      ((last . words . quote . clean) $ rawHighlight) `shouldBe` "rule."
