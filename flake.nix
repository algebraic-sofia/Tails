{
  description = "Tail call optimization for idris inspired in purescript-tailrec and purescript-transformers";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url       = "github:numtide/flake-utils";
    idris2-pkgs.url = "github:claymager/idris2-pkgs";
  };

  outputs = { self, nixpkgs, utils, idris2-pkgs }:
    utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; overlays = [ idris2-pkgs.overlay ]; };
        project  = "tails"; 
        packages = with pkgs; [ idris2.withLibs.sop.elab-util.contrib.network ]; 
        shellInputs = with pkgs.idris2-pkgs; packages ++ 
          [ lsp.withLibs.sop.elab-util.contrib.network
            pkgs.rlwrap 
            pkgs.entr 
          ];
    in { 
      defaultPackage = pkgs.stdenv.mkDerivation rec {
        name = "build-${project}";
        src = self;
        buildPhase = "idris2 --build ${project}.ipkg";
        installPhase = ''
          mkdir -p $out/bin
          cp -r ./build/exec/* $out/bin
          mv $out/bin/${project} $out/bin/build-${project}
        '';
        buildInputs = packages;
      };
      devShell = with pkgs; mkShell { buildInputs = shellInputs; };  
    });
}
