defnix:

{ pkgs
, name ? "myservice"
}:

let

  inherit (pkgs) writeScript bash;

in {
  start = writeScript "myservice" ''
    #!${bash}/bin/bash
    echo "Running my ${name} service"
  '';

  on-demand = false;
}
