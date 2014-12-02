{ args, lib }:

with builtins;

let

  # backendCount is the knob that can be used to scale up or down,
  # either manually or automatically.
  # Automatic scaling would require an external agent that can
  # inspect the performance of the running systemm, decide on
  # a new value for backendCount, commit changes here and then
  # perform a deployment

  backendCount = 3;


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

  io-deployment = defnix: nixpkgs-src: let

    pkgs = import nixpkgs-src { inherit (defnix.config) system; };

    inherit (pkgs.lib) nameValuePair range listToAttrs mapAttrs';

    nixops-multi-deploy = import ./nixops-multi-deploy.nix defnix nixpkgs-src;

    # Put all functionalities into one machine
    mkAllInOneInfrastructure = machineTmpl: functionalities: {
      machine = machineTmpl // { inherit functionalities; };
    };

    # Put every functionality on its own machine
    mkOneToOneInfrastructure = machineTmpl: functionalities: mapAttrs'
      (fn: f: nameValuePair "machine-${fn}"
        (machineTmpl // { functionalities = { "${fn}" = f; }; }))
      functionalities;

    machineTmpl = {
      memory = 2048;
    };

    mkFun = i: {
      service = import ./service.nix defnix pkgs { name = "service-f${toString i}"; };
    };

    functionalities =
      listToAttrs (map (i: nameValuePair "f${toString i}" (mkFun i)) (range 1 backendCount));

    in nixops-multi-deploy (mkOneToOneInfrastructure machineTmpl functionalities);
   #in nixops-multi-deploy (mkAllInOneInfrastructure machineTmpl functionalities);

in bind io-defnix (dn: bind io-nixpkgs-src (io-deployment dn))
