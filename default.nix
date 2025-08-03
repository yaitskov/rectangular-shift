{ system ? builtins.currentSystem or "x86_64-linux"
, ghc ? "ghc9122"
, sources ? import (if builtins.pathExists /home/dan/pro/nixpkgs
                    then ./nix/offline/sources.nix
                    else ./nix/sources.nix)
}:
let
  np = import sources.nixpkgs {
    overlays = [ (n: o: { hamacs = (import sources.hamacs { inherit sources ghc system; }).hamacs; }) ];
  };
  hp = np.haskell.packages.${ghc};

  inherit (np.haskell.lib) dontHaddock;
  inherit (np) lib;

  sourceRegexes = [ "^.*\\.hs$" "^(LICENSE|rectangular-shift|test.el)$" "^.*\\.cabal$" ];

  # cabal build output is not used because hamacs interprets cabal package
  emacs-integration-test = drv:
    drv.overrideAttrs (oa: {
      buildInputs = (oa.builtInputs or []) ++ [np.emacs];
      checkPhase = (oa.checkPhase or "") + ''
        echo Emacs Integration Tests
        export NIX_GHC_LIBDIR=${(hp.ghcWithPackages (h: (rectangular-shift.getCabalDeps.libraryHaskellDepends)))}/lib/ghc-9.12.2/lib
        emacs -Q -L ${np.hamacs}/lib --batch -l test.el
      '';
    });

  rectangular-shift =
    (hp.callCabal2nix "rectangular-shift" (lib.sourceByRegex ./. sourceRegexes) { })
      |> emacs-integration-test |> dontHaddock;

  shell = hp.shellFor {
    packages = p: [ rectangular-shift ];
    nativeBuildInputs = (with np; [
      cabal-install
      ghcid
      hlint
      niv
      emacs
    ]) ++ [ hp.haskell-language-server ];
    shellHook = ''
      export PS1='$ '
      # extract path to emacs-module.h from prefix
      echo $(dirname $(dirname $(which ghc)))/share/doc > .haddock-ref
      echo "Run [hamacs-test] instead of [cabal test]"
      function hamacs-test() {
        emacs -Q -L ${np.hamacs}/lib --batch -l test.el
      }
    '';
  };
in {
  inherit shell;
  inherit rectangular-shift;
}
