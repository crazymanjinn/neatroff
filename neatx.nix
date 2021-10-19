version:
{ stdenv
, lib
, manPkg ? null
, pname
, sourceRoot ? null
, src
}:
let
  installMan = lib.isStorePath manPkg;
in
stdenv.mkDerivation {
  inherit pname version src sourceRoot;
  buildInputs = if installMan then [ manPkg ] else [ ];

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/bin
    cp --reflink=auto ${pname} $out/bin
  '' + (if installMan then ''
    mkdir -p $out/share/man/man1
    cp --reflink=auto ${manPkg}/man/neat${pname}.1 $out/share/man/man1/${pname}.1
  '' else "");

  hardeningDisable = [ "format" ];

  meta.homepage = "http://litcave.rudi.ir/";
  meta.license = lib.licenses.mit;
}
