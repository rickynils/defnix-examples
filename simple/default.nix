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

  functionalities = defnix: pkgs: {

    f1 = {
      service = import ./service.nix defnix pkgs { name = "service-f1"; };
    };

    f2 = {
      service = import ./service.nix defnix pkgs { name = "service-f2"; };
    };

  };

  io-deployment = defnix: nixpkgs-src: with defnix.defnixos.functionalities; let

    pkgs = import nixpkgs-src { inherit (defnix.config) system; };

    fs = functionalities defnix pkgs;

    test = lib.unit (nixos-qemu-test (defnix.lib.map-attrs (n: v: v // {
      inherit nixpkgs-src;
      unit-test-command = "true";
    }) fs));

    vbox = nixops-deploy (defnix.lib.map-attrs (n: v: v // {
      inherit nixpkgs-src;
      nixops-name = "mydeploy";
      nixops-description = "mydeploy";
      nixops-deploy-target = "virtualbox";
    }) fs);

  in if length args > 1 && (elemAt args 1) == "test" then test else vbox;

in bind io-defnix (dn: bind io-nixpkgs-src (io-deployment dn))
