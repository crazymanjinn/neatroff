{ stdenv
, lib
, ghostscript
, gyre-fonts
, gyreSupport ? true
, nixpkgs
, neatmkfn
, mkfn
}:
let
  fonts = [ ghostscript ] ++ (if gyreSupport then [ gyre-fonts ] else [ ]);
in
stdenv.mkDerivation {
  pname = "roff-fonts";
  version = lib.trivial.release + "-g" + nixpkgs.shortRev;
    buildInputs = [ neatmkfn mkfn ] ++ fonts;
  srcs = ./.;

  enableParallelBuilding = true;

  postUnpack = ''
    mkdir -p $sourceRoot/fonts/truetype $sourceRoot/fonts/postscript
    pushd $sourceRoot/fonts
    set +e
    for f in ${lib.concatStringsSep " " fonts}; do
      find -L $f/share/fonts -xdev -type f -name '*.[ot]tf' -print0 |
        xargs -0 -tr cp --reflink=auto -t ./truetype
      find -L $f/share -xdev -type f -name '*.afm' -print0 |
        xargs -0 -tr cp --reflink=auto -t ./postscript
    done
    set -e
    popd

    substitute ${neatmkfn}/gen.sh $sourceRoot/gen.sh --replace ./mkfn mkfn
    chmod a+x $sourceRoot/gen.sh
  '';

  makeFlags = [ "DESTDIR=$(out)" "datarootdir=/share" ];

  buildFlags = [ "GENSH=./gen.sh" ];

  meta.licenses = lib.unique (map (d: d.meta.license) fonts) ++
    [ lib.licenses.mit ];
}
