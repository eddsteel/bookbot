{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE OverloadedStrings         #-}
{-# LANGUAGE TypeFamilies              #-}
module BookBot.Image where

import BookBot.Data(Highlight, hlRenderLines)
import Data.List.Split ()
import Diagrams.Prelude hiding (Highlight, Render)
import Diagrams.TwoD.Text ()
import Diagrams.Backend.SVG
import Graphics.Rendering.Cairo
import qualified Graphics.Rendering.Cairo.SVG as S
import Graphics.Svg.Core (renderText)
import qualified Data.Text.Lazy as T

type Dia = QDiagram Diagrams.Backend.SVG.SVG V2 Double Any

doRender :: S.SVG -> Render ()
doRender svg = do
  save
  setSourceRGBA 1.0 1.0 1.0 1.0
  paint
  restore
  _ <- S.svgRender svg
  return ()

saveImg :: Dia -> FilePath -> IO ()
saveImg d p = do
    let options = SVGOptions (mkWidth 920) Nothing "" [] True
    let elt = renderDia SVG options d
    svg <- S.svgNewFromString (T.unpack (renderText elt))
    let (w, h) = S.svgGetSize svg
    withImageSurface FormatARGB32 w h $ \ surface -> do
      renderWith surface $ doRender svg
      surfaceWriteToPNG surface p

render :: Highlight -> Dia
render hl = font "PT Serif" $ dia <> strutX 920
  where
    ls = 28
    (lns, footer) = hlRenderLines hl
    szd = fontSize (local ls)
    quote = (\t -> text t # szd <> strutY ls) <$> lns
    foot = extrudeTop 20.0 . vcat $ (\t -> text t # bold . szd <> strutY (1.3 * ls)) <$> footer
    dia = extrudeTop 100.0 $ extrudeBottom 100.0 $ vcat quote === foot
