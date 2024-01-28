{ pkgs }: with pkgs;
let
  # This provides a development environment that can be used with nix-shell or
  # lorri. See https://input-output-hk.github.io/haskell.nix/user-guide/development/
  shell = hasktorchSkeletonHaskellPackages.shellFor {
    name = "hasktorch-skeleton-dev-shell";

    tools = {
      cabal = "3.2.0.0";
      haskell-language-server = "latest";
    };

    # Prevents cabal from choosing alternate plans, so that
    # *all* dependencies are provided by Nix.
    # TODO: Set to true as soon as haskell.nix issue #231 is resolved.
    exactDeps = false;

    shellHook = ''
      export CPATH=${torch}/include/torch/csrc/api/include
    '';

    inherit withHoogle;
  };

in

 shell
