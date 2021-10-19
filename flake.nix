{
  description = "Neatroff troff clone";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.neateqn.url = "github:aligrudi/neateqn/20210817";
  inputs.neatmkfn.url = "github:aligrudi/neatmkfn/20210817";
  inputs.neatpost.url = "github:aligrudi/neatpost/20210817";
  inputs.neatrefer.url = "github:aligrudi/neatrefer/20210817";
  inputs.neatroff.url = "github:aligrudi/neatroff/20210817";
  inputs.neatroff_make.url = "github:aligrudi/neatroff_make/20210817";
  inputs.neateqn.flake = false;
  inputs.neatmkfn.flake = false;
  inputs.neatpost.flake = false;
  inputs.neatrefer.flake = false;
  inputs.neatroff.flake = false;
  inputs.neatroff_make.flake = false;

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , neateqn
    , neatmkfn
    , neatpost
    , neatrefer
    , neatroff
    , neatroff_make
    }:
    let
      version = "20210817";
    in
    {
      overlay = final: prev:
        let
          pkgs = nixpkgs.legacyPackages.${prev.system};
          mkNeatX = pkgs.callPackage (import ./neatx.nix version);
          simpleNeatX = { pname, src }: mkNeatX {
            inherit pname src;
            manPkg = neatroff_make;
          };
          mkPlan9 = pkgs.callPackage ./plan9.nix;
          neatX =
            pkgs.lib.mapAttrs
              (pname: value: simpleNeatX {
                inherit pname;
                inherit (value) src;
              })
              {
                eqn = { src = neateqn; };
                mkfn = { src = neatmkfn; };
                refer = { src = neatrefer; };
              } //
            pkgs.lib.mapAttrs
              (pname: value: mkNeatX {
                inherit pname;
                src = neatroff_make;
                sourceRoot = "source/${pname}";
              })
              {
                soin = null;
                shape = null;
              } //
            pkgs.lib.mapAttrs (pname: value: mkPlan9 { inherit pname; }) {
              pic = null;
              tbl = null;
            };
          roff-fonts = pkgs.callPackage ./roff-fonts {
            inherit (neatX) mkfn;
            inherit neatmkfn nixpkgs;
          };
          roff-macros = pkgs.callPackage ./roff-macros.nix {
            inherit neatroff_make version;
          };
          subPackages =
            neatX //
            {
              inherit roff-fonts roff-macros;
              roff = (simpleNeatX {
                pname = "roff";
                src = neatroff;
              }).overrideAttrs (oldAttrs: {
                propagatedBuiltInputs = [ roff-fonts roff-macros ];
                buildFlags = [
                  "FDIR=${roff-fonts}/share/neatroff/font"
                  "MDIR=${roff-macros}/share/neatroff/tmac"
                ];
              });
              post = (simpleNeatX {
                pname = "post";
                src = neatpost;
              }).overrideAttrs (oldAttrs: {
                propagatedBuiltInputs = [ roff-fonts ];
                buildFlags = [
                  "FDIR=${roff-fonts}/share/neatroff/font"
                ];
              });
            };
        in
        {
          neatroff = (pkgs.symlinkJoin {
            name = "neatroff";
            paths = pkgs.lib.attrValues subPackages;
          }).overrideAttrs (oldAttrs: {
            pname = oldAttrs.name;
            name = "${oldAttrs.name}-${version}";
            inherit version;
            meta.mainProgram = "roff";
          } // subPackages);
        };
    } //
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        overlays = [ self.overlay ];
        inherit system;
      };
    in
    {
      legacyPackages = {
        inherit (pkgs.neatroff)
          eqn
          mkfn
          pic
          post
          refer
          roff
          roff-fonts
          roff-macros
          shape
          soin
          tbl
          ;
      };
      packages = { inherit (pkgs) neatroff; };
      defaultPackage = pkgs.neatroff;
    });
}
