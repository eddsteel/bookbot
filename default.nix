{ pkgs ? import <nixpkgs> {} }:

let
  hpkgs = pkgs.haskellPackages.override {
    overrides = hself: hsuper: {
      svgcairo = hsuper.svgcairo.overrideAttrs (attrs: {
        hardeningDisable = ["all"];
      });
      bookbot = (hself.callPackage ./bookbot.nix {}).overrideAttrs (attrs: {
        fixupPhase = ''
          mkdir $out/fonts
          cp -r fonts/* $out/fonts
        '';
      });
    };
  };
in hpkgs.bookbot
