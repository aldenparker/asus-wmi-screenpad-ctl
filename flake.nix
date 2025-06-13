{
  description = "A helper program for the asus-wmi-screenpad kernel module for linux.";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  outputs =
    { pkgs, flake-utils, ... }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      pkgs.rustPlatform.buildRustPackage {
        pname = "asus-wmi-screenpad-ctl";
        version = "1.0.0";

        src = ./.;

        useFetchCargoVendor = true;
        cargoHash = "";
      }
    ));
}
