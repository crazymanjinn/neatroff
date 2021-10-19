{ stdenv, plan9port, pname }:
stdenv.mkDerivation {
  inherit pname;
  inherit (plan9port) version;
  buildInputs = [ plan9port ];

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1
    cp --reflink=auto ${plan9port}/plan9/bin/${pname} $out/bin
    cp --reflink=auto ${plan9port}/plan9/man/man1/${pname}.1 $out/share/man/man1
  '';

  meta = { inherit (plan9port.meta) homepage license; };
}
