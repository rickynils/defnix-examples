{ args, lib }:

let

  bind = ma: f: lib.join (lib.map f ma);

  io-nixpkgs-src = lib.builtins.fetchgit {
    url = "git://github.com/NixOS/nixpkgs.git";
    rev = "c1985405cceae6535077bfb55e995da994e43f2f";
  };

  io-defnix-src = lib.builtins.fetchgit {
    url = "git://github.com/zalora/defnix.git";
    rev = "c11d869426f7d8f158833d91de94cb5d6d0a278b";
  };

  io-defnix = bind io-defnix-src (p: import p lib { });

  functionalities = defnix: pkgs: {

    f1 = {
      service = import ./service.nix defnix pkgs { name = "service-f1"; };
    };

    f2 = {
      service = import ./service.nix defnix pkgs { name = "service-f2"; };
    };

  };

  io-deployment = defnix: nixpkgs-src:
    let
      pkgs = import nixpkgs-src { inherit (defnix.config) system; };
      fs = functionalities defnix pkgs;
      deployment = defnix.lib.map-attrs (n: v: v // {
        inherit nixpkgs-src;
        nixops-name = "mydeploy";
        nixops-description = "mydeploy";
        nixops-deploy-target = "virtualbox";
      }) fs;
    in defnix.defnixos.functionalities.nixops-deploy deployment;

in bind io-defnix (dn: bind io-nixpkgs-src (io-deployment dn))
