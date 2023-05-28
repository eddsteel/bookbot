{ pkgs ? import <nixpkgs> {} }:

let
  hpkgs = pkgs.haskellPackages.override {
    overrides = hself: hsuper: {
      twitter-types = pkgs.haskell.lib.dontCheck hsuper.twitter-types;
      svgcairo = hsuper.svgcairo.overrideAttrs (attrs: {
        hardeningDisable = ["all"];
      });
      bookbot = (hself.callPackage ./bookbot.nix {}).overrideAttrs (attrs: {
        enableExecutableProfiling = true;
        enableLibraryProfiling = true;
        fixupPhase = ''
          mkdir $out/fonts
          cp -r fonts/* $out/fonts
        '';
      });
    };
  };
in hpkgs.bookbot
