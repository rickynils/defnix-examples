defnix: pkgs:

{ name ? "myservice" }:

with pkgs;

{
  start = writeScript "myservice" ''
    #!${bash}/bin/bash
    echo "Running my ${name} service"
  '';

  on-demand = false;
}
