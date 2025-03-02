{
  description = "Spond Ruby Client";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        spondRuby = pkgs.bundlerEnv {
          name = "gemset";
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = ./gemset.nix;
        };
      in {

      defaultPackage = spondRuby;

      # used by nix shell and nix develop
      devShell = with pkgs;
        mkShell {
          buildInputs = [
            ruby_3_4
            bundix

            # For psych gem:
            libyaml
          ];
      };
  });
}
