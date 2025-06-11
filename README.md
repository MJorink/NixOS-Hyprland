AS OF NOW NOT TESTED AT ALL, IM STILL WORKING ON IT.

THERE IS A 0.1% CHANCE IT WILL JUST WORK RIGHT NOW.

<summary>📜 1. Using auto install Script: <</summary>
<br>
<div id="autoinstall">
    
- This is the easiest and recommended way of starting out. 
- This script is NOT meant to allow you to change every option that you can in the flake.
- It won't help you install extra packages.
- It is simply here so you can get my configuration installed with as little chance of breakages.
- It is up to you to fiddle with to your heart's content!
- Simply copy this and run it:
```
nix-shell -p git vim curl pciutils
sh <(curl -L https://github.com/JaKooLit/NixOS-Hyprland/raw/main/auto-install.sh)
```
> [!NOTE]
> pciutils is necessary to detect if you have an Nvidia card. 
