{ pkgs ? import <nixpkgs> {}, tag ? "latest"} :
let
  bookbot = (import ./default.nix {});
  staticExe = pkgs.haskell.lib.justStaticExecutables bookbot;
  fontsDir = pkgs.copyPathToStore ./fonts;
  fontsConf = pkgs.writeTextFile {
    name = "fonts.conf";
    destination = "/fonts.conf"; # so we get a dir
    text = ''
    <?xml version='1.0'?>
    <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
    <fontconfig>
      <cachedir>/.cache/fontconfig</cachedir>
      <dir>${fontsDir}</dir>
      <dir>${pkgs.dejavu_fonts}/share/fonts</dir>
    </fontconfig>
    '';
  };
in pkgs.dockerTools.buildImage {
  name = "bookbot-post";
  inherit tag;
  contents = with pkgs; [ locale fontconfig cairo librsvg cacert fontsConf fontsDir dejavu_fonts bash coreutils ];
  config.Cmd = [ "${staticExe}/bin/post" ];
  runAsRoot = ''
  #!${pkgs.runtimeShell}
  mkdir -p /.cache/fontconfig
  mkdir -p /etc/fonts
  mkdir -m 1777 tmp

  cp ${fontsConf}/fonts.conf /etc/fonts/fonts.conf
  fc-cache -v -f ${fontsDir} -f ${pkgs.dejavu_fonts}/share/fonts
  '';
}
