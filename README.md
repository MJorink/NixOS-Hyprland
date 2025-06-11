
<details>
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
</details>

<details>
<summary>🦽 2. Manual: </summary>
<br>
<div id="manualinstall">

- Run this command to ensure git, curl, vim & pciutils are installed: Note: or nano if you prefer nano for editing
```
nix-shell -p git vim curl pciutils
```
- Clone this repo & CD into it:
```
git clone --depth 1 https://github.com/JaKooLit/NixOS-Hyprland.git ~/NixOS-Hyprland
cd ~/NixOS-Hyprland
```
- *You should stay in this directory for the rest of the install*
- Create the host directory for your machine(s)
```
cp -r hosts/default hosts/<your-desired-hostname>
```
- Edit as required the `config.nix` , `packages-fonts.nix` and/or `users.nix` in `hosts/<your-desired-hostname>/`
- then generate your hardware.nix with:
```
sudo nixos-generate-config --show-hardware-config > hosts/<your-desired-hostname>/hardware.nix
```
- Run this to enable flakes and install the flake replacing hostname with whatever you put as the hostname:
```
NIX_CONFIG="experimental-features = nix-command flakes" 
sudo nixos-rebuild switch --flake .#hostname
```

Once done, you can install the GTK Themes and Hyprland-Dots. Links are above

</div>
</details>

<details>
<summary>👉🏻 3. Alternative </summary>
    
- auto install by running `./install.sh` after cloning and CD into NixOS-Hyprland
> [!NOTE]
> install.sh is a stripped version of auto-install.sh as it will not re-download repo

- Run this command to ensure git, curl, vim & pciutils are installed: Note: or nano if you prefer nano for editing
```
nix-shell -p git curl pciutils
```

- Clone this repo into your home directory & CD into it:
```
git clone --depth 1 https://github.com/JaKooLit/NixOS-Hyprland.git ~/NixOS-Hyprland
cd ~/NixOS-Hyprland
```
</details>


> [!IMPORTANT]
> need to download in your home directory as some part of the installer are going back again to ~/NixOS-Hyprland

- *You should stay in this directory for the rest of the install*
- edit `hosts/default/config.nix` to your liking. Once you are satisfied, ran `./install.sh`
Now when you want to rebuild the configuration, you have access to an alias called `flake-rebuild` that will rebuild the flake!

</details>
