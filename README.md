# asus-wmi-screenpad-ctl

This is a small application that is meant to be used with the [asus-wmi-screenpad kernal module](https://github.com/Plippo/asus-wmi-screenpad). This program allows for simple and safe adjustment of the brightness for the Asus Screenpad. It will probably only be useful for those that do not use standard desktop enviornements like KDE.

## Install

### NixOS
```
# In Flake.nix
inputs.asus-wmi-screenpad-ctl.url = "github:aldenparker/asus-wmi-screenpad-ctl"
```

```
# In nix config
environment.systemPackages = with pkgs; [
  environment.systemPackages = [
    inputs.asus-wmi-screenpad-ctl.packages."${system}".default
  ];
];
```

### Manual
```
cargo build -r
sudo cp ./target/release/asus-wmi-screenpad-ctl /bin/
```
Or copy wherever else the path points to.

## Usage

```
Small application to control the asus-wmi-screenpad brightness

Usage: asus-wmi-screenpad-ctl <MODE> <DATA>

Arguments:
  <MODE>
          The mode to run the command in

          Possible values:
          - set: Set the brightness value
          - add: Add to the brightness value (negative value for decrease)
          - max: Set the max brightness to allow (defaults to 100, just because you can set it higher does not mean your screen can handle it)

  <DATA>
          The value used to modify the brightness value

Options:
  -h, --help
          Print help (see a summary with '-h')

  -V, --version
          Print version
```
