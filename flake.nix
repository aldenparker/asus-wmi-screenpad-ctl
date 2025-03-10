{
  description = "A helper program for the asus-wmi-screenpad kernel module for linux.";

  inputs = {
    zig2nix.url = "github:Cloudef/zig2nix";
  };

  outputs =
    { zig2nix, ... }:
    let
      flake-utils = zig2nix.inputs.flake-utils;
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        env = zig2nix.outputs.zig-env.${system} { zig = zig2nix.outputs.packages.${system}.zig-0_14_0; };
        pkgs = env.pkgs;
      in
      {
        packages.default = env.package rec {
          pname = "asus-wmi-screenpad-ctl";
          version = "1.0.0";

          src = ./.;

          zigBuildZonLock = ./build.zig.zon2json-lock;

          zigBuildFlags = [
            "-Doptimize=ReleaseFast"
          ];
        };
      }
    ));
}
