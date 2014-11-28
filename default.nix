{ args, lib }:

let

  bind = ma: f: lib.join (lib.map f ma);

  io-nixpkgs = lib.builtins.fetchgit {
    url = "git://github.com/NixOS/nixpkgs.git";
    rev = "c1985405cceae6535077bfb55e995da994e43f2f";
  };

  io-defnix-src = lib.builtins.fetchgit {
    url = "git://github.com/zalora/defnix.git";
    rev = "c11d869426f7d8f158833d91de94cb5d6d0a278b";
  };

  io-defnix = bind io-defnix-src (p: import p lib { });

  io-deployment = defnix: nixpkgs-src: defnix.defnixos.functionalities.nixops-deploy {

    f1 = {
      service = import ./service.nix defnix nixpkgs-src { name = "service-f1"; };
      inherit nixpkgs-src;
      nixops-name = "mydeploy1";
      nixops-description = "mydeploy1";
      nixops-deploy-target = "virtualbox";
    };

    f2 = {
      service = import ./service.nix defnix nixpkgs-src { name = "service-f2"; };
      inherit nixpkgs-src;
      nixops-name = "mydeploy2";
      nixops-description = "mydeploy2";
      nixops-deploy-target = "virtualbox";
    };

  };

in bind io-defnix (dn: bind io-nixpkgs (io-deployment dn))
