+++
title="Using a specific package version in Nix"
date=2022-12-12

[taxonomies]
tags = ["haskell", "nix"]
+++
As part of my journey to learn Haskell, I recently started reading Haskell in Depth by Vitaly Bragilevsky. The book has an associated repository with code examples that is supposed to
be compiled with GHC 8.6 and newer. I thought that I could just build a simple `shell.nix` file (TODO: file / derivation ?) that installed the required dependencies. Although the project is
prepared to be compiled with both cabal and stack, all the development environments for Haskell that I had created up until then with Nix used stack, so I wanted to give cabal a try. Besides, I had recently skimmed through Gabriela Gonzalez's haskell-nix repository[^1], in which she suggests that Nix complements quite well 
with cabal, while being more a stack substitute.

It turns out that my goal would not be so easy to accomplish. Since the beginning, I started facing some issues with dependencies: some of them were missing and apparently unreachable, others were conficting, and so on. I played around with some different approaches hoping that at some point I would be lucky. Neither installing cabal and then running `cabal build` nor using cabal2nix worked. I suspect that the problems with the latter are related to the fact that there are multiple executables in the project, but cabal2nix only works with one 
(TODO: confirm that this is an issue).

At some point, I decided that maybe it would be good to reproduce as much as possible the environment that the author used when developing the project. The 8.8.3 version of the GHC was no longer available in the unstable nix-channel, so I had to do some research to find a way to retrieve it. In the end I came across this [website](https://lazamar.co.uk/nix-versions/) which makes it possible to find all versions that were available in a nixpkgs channel for the required package and automatically creates some Nix code to retrieve it. I do not know if there are other ways to achieve the same, but for a Nix newbie like me, it was extremely helpful. With some minor additions, I was able to create a working `shell.nix`:

```nix
let
  # This nixpkgs version corresponds to the ghc-8.8.3
  pkgs = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/2d9888f61c80f28b09d64f5e39d0ba02e3923057.tar.gz";
    })
    { };
in
pkgs.mkShell {
  name = "dev-environment";
  buildInputs = [
    pkgs.ghc
    pkgs.cabal-install
    pkgs.ghcid
    pkgs.zlib
  ];
  shellHook = ''
    echo "Running cabal build..."
    cabal build

    echo "Start developing"
  '';
}
```

Now I can happily continue learning Haskell again!

[^1] I have not studied it in detail, but I will definitely will do at some point.
