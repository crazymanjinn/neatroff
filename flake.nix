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
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      version = "20210817";

      subPackages = pkgs.lib.filterAttrs (n: v: pkgs.lib.isDerivation v) (
        pkgs.callPackage ./sub-packages.nix {
          inherit
            neateqn
            neatmkfn
            neatpost
            neatrefer
            neatroff
            neatroff_make
	    nixpkgs
            version
            ;
        }
      );
    in
    rec {
      packages = {
        neatroff = pkgs.callPackage ./neatroff.nix {
          inherit version subPackages;
        };
      } // flake-utils.lib.flattenTree subPackages;
      defaultPackage = packages.neatroff;

      apps = pkgs.lib.mapAttrs (n: v: flake-utils.lib.mkApp { drv = v; })
        subPackages;
    });
}
