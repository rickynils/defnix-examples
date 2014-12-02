defnix: nixpkgs: infrastructure:

with builtins;

let

  pkgs = import nixpkgs { inherit (defnix.config) system; };

  inherit (pkgs.lib) mapAttrsToList concatStrings;

  assertions =
    # stupid assertion for now
    (length machines == length functionalities);

  inherit (defnix.native.nix-exec.pkgs) nixops;

  inherit (defnix.native.build-support) write-file;

  inherit (defnix.nix-exec) spawn;

  inherit (defnix.lib) imap;

  inherit (defnix.lib.nix-exec) bind;

  inherit (defnix.defnixos.functionalities) generate-nixos-config;

  mkMachineExpr = name: machine: ''
    ${name} = {
      imports = [ ${generate-nixos-config machine.functionalities} ];
      deployment = {
        targetEnv = "virtualbox";
          virtualbox = {
          memorySize = ${toString machine.memory};
          headless = true;
        };
      };
    };
  '';

  expr = write-file "deployment.nix" ''
    {
      ${concatStrings (mapAttrsToList mkMachineExpr infrastructure)}
    }
  '';

  run-nixops = cmd:
    spawn nixops [ cmd "-d" "defnix" "-I" "nixpkgs=${nixpkgs}" expr ];

  modify = run-nixops "modify";

  create = run-nixops "create";

  deploy = spawn nixops [
    "deploy"
    "-d"
    "defnix"
    "--option"
    "allow-unsafe-native-code-during-evaluation"
    "true"
  ];

  run = bind modify ({ signalled, code }: if signalled
    then throw "nixops modify killed by signal ${toString code}"
    else if code != 0
      then bind create ({ signalled, code }: if signalled
        then throw "nixops create killed by signal ${toString code}"
        else if code != 0
          then throw "nixops create exited with code ${toString code}"
          else deploy)
      else deploy);
in run
