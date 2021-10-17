{ symlinkJoin, lib, subPackages, version }:
(symlinkJoin {
  name = "neatroff";
  paths = (lib.attrValues subPackages);
}).overrideAttrs (oldAttrs: {
  pname = oldAttrs.name;
  name = "${oldAttrs.name}-${version}";
  inherit version;
  meta.mainProgram = "roff";
})
