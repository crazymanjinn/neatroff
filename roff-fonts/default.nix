{ stdenv
, extraFontPkgs ? [ ]
, ghostscript
, gyre-fonts
, lib
, mkfn
, python3
}:
let
  fonts = [ ghostscript gyre-fonts ] ++ extraFontPkgs;
in
stdenv.mkDerivation {
  pname = "roff-fonts";
  version = lib.trivial.release;
  buildInputs = [
    fonts
    mkfn

    (python3.withPackages (p: with p; [ fontforge ]))
  ];

  srcs = ./.;

  enableParallelBuilding = true;

  postUnpack = ''
    fDir=$sourceRoot/fonts
    mkdir -p $fDir/{afm,otf,ttf}
    for fType in afm otf ttf; do
      mkdir -p $fDir/$fType
      for d in ${lib.concatStringsSep " " fonts}; do
        find -L $d/share -xdev -type f -name "*.$fType" -print0 |
          xargs -0 -tr cp --reflink=auto -t $fDir/$fType
      done
    done
  '';

  postPatch = ''
    patchShebangs --build extract_font_names
  '';

  makeFlags = [ "DESTDIR=$(out)" "datarootdir=/share" ];

  meta.licenses = lib.unique (map (d: d.meta.license) fonts) ++
    [ lib.licenses.mit ];
}
