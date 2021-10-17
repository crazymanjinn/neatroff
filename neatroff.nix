{ symlinkJoin, lib, subPackages, version }:
(symlinkJoin {
  name = "neatroff";
  paths = (lib.attrValues subPackages);
}).overrideAttrs (oldAttrs: {
  meta.mainProgram = "roff";
})
