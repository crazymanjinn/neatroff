{ stdenv
, callPackage
, lib
, neateqn
, neatmkfn
, neatpost
, neatrefer
, neatroff
, neatroff_make
, nixpkgs
, plan9port
, version
}:
let
  mkSubDerivation =
    { pname
    , src
    , sourceRoot ? null
    , man ? null
    }: stdenv.mkDerivation {
      inherit pname version src sourceRoot;

      buildInputs = if (lib.isStorePath man) then [ man ] else [ ];

      enableParallelBuilding = true;
      hardeningDisable = [ "format" ];

      installPhase = ''
        mkdir -p $out/bin
        cp --reflink=auto ${pname} $out/bin
      '' + (if (lib.isStorePath man) then ''
        mkdir -p $out/share/man/man1
        cp --reflink=auto ${man}/man/neat${pname}.1 $out/share/man/man1/${pname}.1
      '' else "");

      meta.homepage = "http://litcave.rudi.ir/";
      meta.license = lib.licenses.mit;
    };

  neatDrvs = lib.mapAttrs
    (name: value: mkSubDerivation {
      pname = name;
      inherit (value) src;
      man = neatroff_make;
    })
    {
      eqn = { src = neateqn; };
      mkfn = { src = neatmkfn; };
      post = { src = neatpost; };
      refer = { src = neatrefer; };
    };

  roffFonts = callPackage ./roff-fonts {
    inherit (neatDrvs) mkfn;
    inherit neatmkfn nixpkgs;
    gyreSupport = true;
  };

  roffMacros = stdenv.mkDerivation {
    pname = "roff-macros";
    inherit version;
    src = neatroff_make;

    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share
      cp -rv --reflink=auto ${neatroff_make}/tmac $out/share
    '';

    meta.homepage = "http://litcave.rudi.ir/";
    meta.licenses = lib.license.mit;
  };

  roff = (mkSubDerivation {
    pname = "roff";
    src = neatroff;
    man = neatroff_make;
  }).overrideAttrs (oldAttrs: {
    propagatedBuildInputs = [ roffFonts roffMacros ];
    buildFlags = [
      "FDIR=${roffFonts}/share/fonts/neatroff"
      "MDIR=${roffMacros}/share/tmac"
    ];
    installPhase = oldAttrs.installPhase + ''
      mkdir -p $out/share/fonts
      cp -r --reflink=auto ${roffFonts}/share/fonts/neatroff $out/share/fonts
    '';
  });

  extractPlan9 = pname:
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
    };
in
{
  inherit roff; inherit (neatDrvs) eqn mkfn post refer;
  roff-fonts = roffFonts;
  roff-macros = roffMacros;
} //
lib.mapAttrs
  (name: value: mkSubDerivation {
    pname = name;
    src = neatroff_make;
    sourceRoot = "source/${name}";
  })
  {
    soin = null;
    shape = null;
  } //
lib.mapAttrs (name: value: extractPlan9 name) { pic = null; tbl = null; }
