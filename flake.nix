# Kudos to https://ilanjoselevich.com/blog/building-websites-using-nix-flakes-and-zola/
{
  description = "A flake for building and developing my website";
  inputs.nixpkgs.url = "nixpkgs/nixos-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.website = pkgs.stdenv.mkDerivation rec {
          pname = "static-website";
          version = builtins.substring 0 8 self.lastModifiedDate;
          src = ./.;
          nativeBuildInputs = [ pkgs.zola ];
          buildPhase = "zola build";
          installPhase = "cp -r public $out";
        };
        defaultPackage = self.packages.${system}.website;
        devShell = pkgs.mkShell { packages = with pkgs; [ zola ]; };
      });
}

