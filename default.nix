{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs.haskell.lib) doJailbreak;
  hpkgs = pkgs.haskellPackages.override {
    overrides = hself: hsuper: {
      svgcairo = hsuper.svgcairo.overrideAttrs (attrs: {
        hardeningDisable = ["all"];
      });
      bookbot = (hself.callPackage ./bookbot.nix {}).overrideAttrs (attrs: {});
    };
  };
in hpkgs.bookbot
