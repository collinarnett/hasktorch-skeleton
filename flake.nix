{
  inputs = {
    tokenizers = {
      url = "github:hasktorch/tokenizers/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hasktorch.url = "github:collinarnett/hasktorch/feature/nix-overhaul";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-nix.follows = "hasktorch/haskell-nix";
    nixpkgs.follows = "hasktorch/nixpkgs";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    tokenizers,
    haskell-nix,
    flake-parts,
    hasktorch,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      perSystem = {
        system,
        pkgs,
        lib,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.cudaSupport = true;
          config.allowUnfree = true;
          overlays = [
            haskell-nix.overlay
            tokenizers.overlay
            hasktorch.overlays.default
            (final: prev: {
              hasktorch-skeleton = final.haskell-nix.cabalProject' {
                src = ./.;
                compiler-nix-name = "ghc924";
                modules = [
                  # Add non-Haskell dependencies
                  {
                    packages.tokenizers = {
                      configureFlags = ["--extra-lib-dirs=${final.tokenizers-haskell}/lib"];
                    };
                    packages.libtorch-ffi = {
                      configureFlags = [
                        "--extra-include-dirs=${lib.getDev final.torch}/include/torch/csrc/api/include"
                      ];
                      flags = {
                        cuda = true;
                      };
                    };
                  }
                ];
              };
            })
          ];
        };
        devShells.default = pkgs.hasktorch-skeleton.shellFor {
          exactDeps = true;
          tools = {
            cabal = {};
            haskell-language-server = {};
          };
        };
      };
    };
}
