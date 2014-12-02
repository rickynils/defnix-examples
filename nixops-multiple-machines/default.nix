{ args, lib }:

with builtins;

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

  machines = [
    { memory = 2048; }
    { memory = 4096; }
  ];

  functionalities = defnix: pkgs: [

    { service = import ./service.nix defnix pkgs { name = "service-f1"; }; }

    { service = import ./service.nix defnix pkgs { name = "service-f2"; }; }

  ];

  nixops-multi-deploy = import ./nixops-multi-deploy.nix;

  io-deployment = defnix: nixpkgs-src:
    let
      pkgs = import nixpkgs-src { inherit (defnix.config) system; };
      fs = functionalities defnix pkgs;
    in nixops-multi-deploy defnix nixpkgs-src machines fs;

in bind io-defnix (dn: bind io-nixpkgs-src (io-deployment dn))
