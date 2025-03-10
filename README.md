# asus-wmi-screenpad-ctl

This is a small application that is meant to be used with the [asus-wmi-screenpad kernal module](https://github.com/Plippo/asus-wmi-screenpad). This program allows for simple and safe adjustment of the brightness for the Asus Screenpad. It will probobly only be useful for those that do not use standard desktop enviornements like KDE.

## Install

### NixOS
```
inputs.asus-wmi-screenpad-ctl.url = "github:aldenparker/asus-wmi-screenpad-ctl"

... # Add Overlay for nix packages (asus-wmi-screenpad-ctl.overlays.default)

environment.systemPackages = with pkgs; [
  asus-wmi-screenpad-ctl
];
```

### Manual
```
zig build
sudo cp ./zig-out/bin/asus-wmi-screenpad-ctl /bin/
```
Or copy wherever else the path points to.

## Usage

```
asus-wmi-screenpad-ctl [FLAG] [DATA]

Flags:
  [-s, --set] [UINT] = Set the brightness level (constrained to max level)
  [-a, --add] [INT]  = Add to brightness level (constrained to max level, negative integer for decrease)
  [-m, --max] [UINT] = Set max level (Just because max is set high, does not mean your display can handle it)
```
