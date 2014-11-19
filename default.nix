{ args, lib }:

let

  system = builtins.currentSystem;

  bind = ma: f: lib.join (lib.map f ma);

  nixpkgs = lib.builtins.fetchgit {
    url = "git://github.com/NixOS/nixpkgs.git";
    rev = "63d936621210076893a0dfbaa0bfe0f90ccdf70d";
  };

  defnix-src = lib.builtins.fetchgit {
    url = "git://github.com/zalora/defnix.git";
    rev = "145da08e0dfde33761e6518ccb9f72d3f74b07d0";
  };

  defnix = bind defnix-src (p: import p lib { config.target-system = system; });

  deployment = defnix: nixpkgs: defnix.defnixos.functionality-implementations.nixops-deploy {
    inherit nixpkgs;
    target = "virtualbox";
    name = "mydeploy";

    functionalities = {};

#    functionalities = {
#      f1 = {
#        service = defnix.defnixos.services.nginx { port = 81; config = ""; };
#      };
#      f2 = {
#        service = defnix.defnixos.services.nginx { port = 82; config = ""; };
#      };
#    };

#    functionalities = let pkgs = import nixpkgs { inherit system; }; in {
#      f1 = {
#        service = import ./service.nix defnix { inherit pkgs; name = "service-f1"; };
#      };
#      f2 = {
#        service = import ./service.nix defnix { inherit pkgs; name = "service-f2"; };
#      };
#    };

  };

in bind defnix (dn: bind nixpkgs (deployment dn))
