{ mkDerivation, aeson, authenticate-oauth, base, bytestring, cairo
, diagrams-core, diagrams-lib, diagrams-svg, directory, filepath
, HandsomeSoup, hpack, hspec, http-conduit, hxt, JuicyPixels, lib
, modern-uri, pooled-io, random, rasterific-svg, regex-compat
, split, svg-builder, svgcairo, text, twitter-conduit
, twitter-types, yaml
}:
mkDerivation {
  pname = "bookbot";
  version = "0.1.0.1";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson authenticate-oauth base bytestring cairo diagrams-core
    diagrams-lib diagrams-svg directory filepath HandsomeSoup
    http-conduit hxt JuicyPixels modern-uri pooled-io random
    rasterific-svg regex-compat split svg-builder svgcairo text
    twitter-conduit twitter-types yaml
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    aeson authenticate-oauth base bytestring cairo diagrams-core
    diagrams-lib diagrams-svg directory filepath HandsomeSoup
    http-conduit hxt JuicyPixels modern-uri pooled-io random
    rasterific-svg regex-compat split svg-builder svgcairo text
    twitter-conduit twitter-types yaml
  ];
  testHaskellDepends = [
    aeson authenticate-oauth base bytestring cairo diagrams-core
    diagrams-lib diagrams-svg directory filepath HandsomeSoup hspec
    http-conduit hxt JuicyPixels modern-uri pooled-io random
    rasterific-svg regex-compat split svg-builder svgcairo text
    twitter-conduit twitter-types yaml
  ];
  prePatch = "hpack";
  homepage = "https://github.com/eddsteel/bookbot#readme";
  license = lib.licenses.gpl3Only;
}
