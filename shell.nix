{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  inputsFrom = [ (import ./default.nix {}).env ];
  buildInputs = with pkgs; [ curl libxml2 direnv pup jq json2yaml ];
}
