+++
title="Using a specific package version in Nix"
date=2022-12-12

[taxonomies]
tags = ["haskell", "nix"]
+++
As part of my journey to learn Haskell, I recently started reading [Haskell in Depth](https://www.manning.com/books/haskell-in-depth) by Vitaly Bragilevsky. The book has an associated repository with code examples that is supposed to be compiled with GHC 8.6 and newer. My idea was to build a simple nix expression that installed the required dependencies. Although the project is prepared to be compiled with both cabal and stack, all the development environments for Haskell that I had created until then used stack, so I wanted to give cabal a try. Besides, I had recently skimmed through Gabriela Gonzalez's [haskell-nix](https://github.com/Gabriella439/haskell-nix) repository, in which she comments that while Nix is more of a stack substitute, it complements quite well with cabal.

Since the beginning, I started facing problems with dependencies. Neither installing cabal and then running `cabal build` nor using cabal2nix worked. I suspect that the problems with the latter were related to the fact that there are multiple executables in the project and cabal2nix did not include all of them in the generated nix expression. I even ended up tyring to use stack, but it failed too.

At some point, I decided that maybe it would be good to reproduce as much as possible the development environment of the author, even if the book claimed that the project worked with newer versions of GHC. The 8.8.3 version was no longer available in the unstable nix-channel, so I had to do some research to find a way to retrieve it. I came across this [website](https://lazamar.co.uk/nix-versions/) which makes it possible to find all the versions that were available in a nixpkgs channel for the required package and automatically creates a Nix expression to retrieve it. I do not know if there are other ways to do the same, but for a Nix newbie like me, this was extremely helpful. With some minor additions, I was able to create the following `shell.nix`:

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
    pkgs.pkg-config
  ];
  shellHook = ''
    echo "Running cabal build..."
    cabal build

    echo "Start developing"
  '';
}
```

Now I can happily continue learning Haskell!

