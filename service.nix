defnix: nixpkgs: let pkgs = import nixpkgs { inherit (defnix.config) system; }; in

{ name ? "myservice" }:

with pkgs;

{
  start = writeScript "myservice" ''
    #!${bash}/bin/bash
    echo "Running my ${name} service"
  '';

  on-demand = false;
}
