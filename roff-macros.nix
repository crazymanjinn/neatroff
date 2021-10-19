{ stdenv, lib, neatroff_make, version }:
stdenv.mkDerivation {
  pname = "roff-macros";
  inherit version;
  src = neatroff_make;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/neatroff/tmac
    cp -rv --reflink=auto ${neatroff_make}/tmac $out/share/neatroff
  '';

  meta.homepage = "http://litcave.rudi.ir/";
  meta.licenses = lib.license.mit;
}
