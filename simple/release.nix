{ nixpkgs ? <nixpkgs> }:

let
  inherit (import nixpkgs {}) nix-exec;

  unsafe-perform-io = import "${nix-exec}/share/nix/unsafe-perform-io.nix";

  lib = import "${nix-exec}/share/nix/lib.nix" unsafe-perform-io;

in {
  test = unsafe-perform-io (import ./default.nix {
    inherit lib;

    args = [ "default.nix" "test" ];
  });
}
