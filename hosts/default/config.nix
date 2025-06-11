{ config, pkgs, host, username, options, lib, inputs, system, ... }:

let
  gitUsername = "JaKooLit"; #You can change these to your own if you want to,
  gitEmail = "ejhay.games@gmail.com"; # These are configured for pulling with git.
  keyboardLayout = "us";
  browser = "zen-browser";
  terminal = "kitty";
  clock24h = true;
  extraMonitorSettings = "";
in

{

  
  imports = [
    ./hardware.nix
    ../../modules/amd-drivers.nix
    ../../modules/nvidia-drivers.nix
    ../../modules/nvidia-prime-drivers.nix
    ../../modules/intel-drivers.nix
    ../../modules/vm-guest-services.nix
    ../../modules/local-hardware-clock.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device"
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco"
      "modprobe.blacklist=iTCO_wdt"
    ];

    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 5;

    tmp.useTmpfs = false;
    tmp.tmpfsSize = "30%";

    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    plymouth.enable = true;
  };

  drivers = {
    amdgpu.enable = false;
    intel.enable = false;
    nvidia.enable = true;
    nvidia-prime.enable = false;
  };

  vm.guest-services.enable = false;
  local.hardware-clock.enable = false;

  networking = {
    networkmanager.enable = true;
    hostName = "${host}";
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  };

  services = {
    xserver = {
      enable = false;
      xkb.layout = keyboardLayout;
    };

    greetd = {
      enable = true;
      vt = 3;
      settings.default_session = {
        user = username;
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
      };
    };

    smartd.enable = false;
    gvfs.enable = true;
    tumbler.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    udev.enable = true;
    envfs.enable = true;
    dbus.enable = true;
    fstrim.enable = true;
    fstrim.interval = "weekly";

    libinput.enable = true;
    rpcbind.enable = false;
    nfs.server.enable = false;
    openssh.enable = true;
    flatpak.enable = true;
    blueman.enable = true;
    fwupd.enable = true;
    upower.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  systemd.services.flatpak-repo = {
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 30;
    swapDevices = 1;
    algorithm = "zstd";
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "Performance";
  };

  hardware = {
    logitech = {
      wireless.enable = false;
      wireless.enableGraphical = false;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
    graphics.enable = true;
  };

  security = {
    rtkit.enable = true;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            subject.isInGroup("users") &&
            (action.id == "org.freedesktop.login1.reboot" ||
             action.id == "org.freedesktop.login1.power-off")
          ) {
            return polkit.Result.YES;
          }
        })
      '';
    };
    pam.services.swaylock.text = "auth include login";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  virtualisation.libvirtd.enable = false;
  virtualisation.podman.enable = false;

  console.keyMap = keyboardLayout;

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    shells = with pkgs; [ zsh ];

	variables = {
		EDITOR = "micro";
		SYSTEMD_EDITOR = "micro";
		VISUAL = "micro";
	};

    systemPackages = with pkgs; [
      lsd fzf bc baobab btrfs-progs clang curl cpufrequtils duf findutils ffmpeg
      glib gsettings-qt git git-lfs killall libappindicator libnotify openssl pciutils wget
      xdg-user-dirs xdg-utils micro fastfetch
      (mpv.override { scripts = [ mpvScripts.mpris ]; })
      inputs.ags.packages.${pkgs.system}.default
      brightnessctl cava cliphist loupe gnome-system-monitor grim gtk-engine-murrine
      hypridle imagemagick inxi jq kitty libsForQt5.qtstyleplugin-kvantum networkmanagerapplet
      nwg-displays nwg-look nvtopPackages.full pamixer pavucontrol playerctl polkit_gnome
      libsForQt5.qt5ct kdePackages.qt6ct kdePackages.qtwayland kdePackages.qtstyleplugin-kvantum
      rofi-wayland slurp swappy swaynotificationcenter swww unzip wallust wl-clipboard wlogout
      xarchiver yad yt-dlp gamemode ncspot mangohud inputs.zen-browser.packages."${system}".default goverlay protonup-qt
      # Add packages / add programs above here
      (pkgs.python3.withPackages (ps: with ps; [ requests pyquery ]))
    ];
  };

  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = gitUsername;
      extraGroups = [ "networkmanager" "wheel" "libvirtd" "scanner" "lp" "video" "input" "audio" ];
      packages = [ ];
    };
    defaultUserShell = pkgs.zsh;
  };

  fonts.packages = with pkgs; [
    dejavu_fonts fira-code fira-code-symbols font-awesome hackgen-nf-font ibm-plex inter
    jetbrains-mono material-icons maple-mono.NF minecraftia nerd-fonts.im-writing
    nerd-fonts.blex-mono noto-fonts noto-fonts-emoji noto-fonts-cjk-sans noto-fonts-cjk-serif
    noto-fonts-monochrome-emoji powerline-fonts roboto roboto-mono symbola terminus_font
    victor-mono
  ];

  programs = {
    hyprland = {
      enable = true;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };

    waybar.enable = true;
    hyprlock.enable = true;
    git.enable = true;
    nm-applet.indicator = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        exo mousepad thunar-archive-plugin thunar-volman tumbler
      ];
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    xwayland.enable = true;
    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "agnoster";
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      promptInit = ''
        fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
        alias ls='lsd'
        alias l='ls -l'
        alias la='ls -a'
        alias lla='ls -la'
        alias lt='ls --tree'
        source <(fzf --zsh)
        HISTFILE=~/.zsh_history
        HISTSIZE=10000
        SAVEHIST=10000
        setopt appendhistory
      '';
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = false;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal ];
  };

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.automatic-timezoned.enable = true;

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
