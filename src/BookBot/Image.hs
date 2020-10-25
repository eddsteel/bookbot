{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE OverloadedStrings         #-}
{-# LANGUAGE TypeFamilies              #-}
module BookBot.Image where

import BookBot.Data(Highlight, hlRenderLines)
import Codec.Picture(writePng)
import Data.List(intersperse)
import Data.List.Split
import Diagrams.Prelude hiding (Highlight, Render)
import Diagrams.TwoD.Text
import Diagrams.Backend.SVG
import Graphics.Rasterific.Svg (loadCreateFontCache, renderSvgDocument)
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
  S.svgRender svg
  return ()


saveImg :: Dia -> FilePath -> IO ()
saveImg d p = do
    let options = SVGOptions (mkWidth 920) Nothing "" [] True
    let element = renderDia SVG options d
    svg <- S.svgNewFromString (T.unpack (renderText element))
    let (w, h) = S.svgGetSize svg
    withImageSurface FormatARGB32 w h $ \ surface -> do
      renderWith surface $ doRender svg
      surfaceWriteToPNG surface p

render :: Highlight -> Dia
render hl = font "Crimson Text" $ dia <> strutX 920
  where
    ls = 28
    lines = hlRenderLines hl
    sized = fontSize (local ls)
    quote = (\t -> text t # sized <> strutY ls) <$> init lines
    footer = extrudeTop 20.0 $ text (last lines) # bold . sized <> strutY (2 * ls)
    dia = extrudeTop 100.0 $ extrudeBottom 100.0 $ vcat quote === footer
