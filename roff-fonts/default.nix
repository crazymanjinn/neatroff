{ stdenv
, extraFontPkgs ? [ ]
, lib
, ghostscript
, gyre-fonts
, nixpkgs
, neatmkfn
, mkfn
}:
let
  fonts = [ ghostscript gyre-fonts ] ++ extraFontPkgs;
in
stdenv.mkDerivation {
  pname = "roff-fonts";
  version = lib.trivial.release + "-g" + nixpkgs.shortRev;
  buildInputs = [ neatmkfn mkfn ] ++ fonts;
  srcs = ./.;

  enableParallelBuilding = true;

  postUnpack = ''
    mkdir -p $sourceRoot/fonts/truetype $sourceRoot/fonts/postscript
    pushd $sourceRoot/fonts > /dev/null
    set +e
    for f in ${lib.concatStringsSep " " fonts}; do
      find -L $f/share/fonts -xdev -type f -name '*.[ot]tf' -print0 |
        xargs -0 -tr cp --reflink=auto -t ./truetype
      find -L $f/share -xdev -type f -name '*.afm' -print0 |
        xargs -0 -tr cp --reflink=auto -t ./postscript
    done
    set -e
    popd > /dev/null
  '';

  patchPhase = ''
    substitute ${neatmkfn}/gen.sh ./gen.sh --replace ./mkfn mkfn
    chmod a+x ./gen.sh
  '';

  makeFlags = [ "DESTDIR=$(out)" "datarootdir=/share" ];

  buildFlags = [ "GENSH=./gen.sh" ];

  meta.licenses = lib.unique (map (d: d.meta.license) fonts) ++
    [ lib.licenses.mit ];
}
