# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages;

  # Boot
  boot.loader.timeout = 1;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Swap
  # In your configuration.nix or hardware-configuration.nix
  swapDevices = [
    {
      device = "/swap/swapfile";
      # Since it's already created, NixOS will just use it.
      # If it wasn't there, NixOS could create it if you added 'size = 16384;'
    }
  ];

  # Network
  networking.hostName = "eiri-coffee";
  networking.networkmanager.enable = true;
  services.openssh = {
    enable = true;
    # Ensure the SFTP subsystem is explicitly enabled
    allowSFTP = true;
    settings = {
      # Sometimes Dolphin struggles if PasswordAuthentication is off
      # unless you have your SSH keys perfectly mapped in ~/.ssh/config
      PasswordAuthentication = true;
      PermitRootLogin = "no"; # Optional, Explicit
    };
  };


  # VPN
  services.tailscale.enable = true;
  # 2. Force tailscaled to use nftables (Critical for clean nftables-only systems)
  # This avoids the "iptables-compat" translation layer issues.
  systemd.services.tailscaled = {
    serviceConfig.Environment = [ "TS_DEBUG_FIREWALL_MODE=nftables" ];
    # Ensure it starts after the network is up but doesn't block boot
#     after = [ "network-pre.target" ];
#     wants = [ "network-pre.target" ];
  };
  # 3. Optimization: Prevent systemd from waiting for network online
  # (Optional but recommended for faster boot with VPNs)
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;


  # Firewall
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    # checkReversePath = "loose"; # Default None
    # Always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];
    # Allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 1234 ]; # Append port to the port list
  };



  # Nvidia Settings
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    # powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # powerManagement.finegrained = true;

    dynamicBoost.enable = true;

    prime = {
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = { enable = true; enableOffloadCmd = true; };
    };
    nvidiaSettings = true;
  };

  # Audio & Printing
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # DE
  services.xserver.enable = true;
  services.displayManager = {
    sddm.enable = true;
    # Enable autologin
    # defaultSession = "hyprland";
    autoLogin = {
      enable = true;
      user = "eiri";
    };
  };
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = { layout = "au"; variant = ""; }; # keymap in x11  

#   xdg.mime.defaultApplications = {
#     "text/html" = "firefox.desktop";
#     "x-scheme-handler/http" = "firefox.desktop";
#     "x-scheme-handler/https" = "firefox.desktop";
#   };


  # Hyperland
  # services.getty.autologinUser = "eiri";
  programs.hyprland = {
    enable = true;
    # withUWSM = true; # systemd wrapper of wayland
    xwayland.enable = true;
  };


  # Essential System Tools
#   programs.nix-ld.enable = true;
#   # Optional: add libraries that the vscode server usually needs
#   programs.nix-ld.libraries = with pkgs; [
#     stdenv.cc.cc
#     zlib
#     fuse3
#     icu
#     nss
#     openssl
#     curl
#     expat
#   ];
  services.flatpak.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network
  };
  environment.systemPackages = with pkgs; [
    # kdePackages.sddm-kcm
    nil
    neovim
    wget
    pciutils
    fastfetch
    python3
    nvtopPackages.full # GPU monitor
    nvitop # Python-based GPU monitor (great for ML)
    kdiskmark
    kdePackages.partitionmanager

    # Hyprland

    # --- Terminals ---
    kitty             # Primary (Nvidia/GPU accelerated)
    foot              # Secondary (CPU-based / Wayland native backup)

    # --- Desktop Essentials ---
    waybar            # The top bar
    rofi      # App launcher (Wayland fork)
    swww              # Wallpaper daemon (smooth transitions)
    # hyprpaper # simple wallpaper

    # --- Notifications (Choose ONE, Dunst is easier for beginners) ---
    dunst             # Notification daemon
    libnotify         # Provides 'notify-send' command
    # mako # notification

    # --- Utils ---
    grim              # Screenshot (take image)
    slurp             # Screenshot (select region)
    wl-clipboard      # Clipboard (copy/paste support)
    pavucontrol       # Audio GUI (essential for Pipewire)
  ];

  # Virtual Machine
#   virtualisation.virtualbox.host.enable = true;
#   users.extraGroups.vboxusers.members = [ "eiri" ];
#   virtualisation.virtualbox.host.enableExtensionPack = true; # Optional: for USB 2.0/3.0 support

  # User
  # users.mutableUsers = false;
  users.users.eiri = {
    isNormalUser = true;
    description = "eiri";
    # hashedPasswordFile = "/home/eiri/nixos-config/secrets/eiri-password-hash";
    extraGroups = [ 
      "networkmanager" # Switch network without sudo
      "wheel"
      "video" # give user direct access to video hardware devices or webcam
    ];
    packages = with pkgs; [
    #  Moved to home.nix
    ];
  };

  # Locale
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Chinese Input
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [ kdePackages.fcitx5-chinese-addons fcitx5-gtk ];
  };
  
  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # English font FIRST, then CJK as the fallback
      serif = [ "Noto Serif" "Noto Serif CJK SC" ];
      sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
      monospace = [ "Noto Sans Mono" "Noto Sans Mono CJK SC" ];
    };
  };

  # Flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.direnv.enable = true;
  # nix.registry.kt.to = { type = "path"; path = "/home/eiri/github/kt"; };




  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  
  system.stateVersion = "25.11"; # Did you read the comment?
}

