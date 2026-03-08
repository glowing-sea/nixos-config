# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


# ====================== (1) My Setting Block Starts ======================= #

let
  # This replaces the 'nix-channel' command entirely
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  home-manager.useGlobalPkgs = true;   # One package list for the whole machine (Faster!)
  home-manager.useUserPackages = true; # Store user apps in the system profile (Cleaner!)

  # ====================== (1) My Setting Block Ends ======================= #


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  # ====================== (2) My Setting Block Starts ======================= #

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;


  networking.hostName = "eiri-coffee"; # Define your hostname.

  # ====================== (2) My Settings Block Ends ======================= #

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  # ====================== (3) My Setting Block Starts ======================= #

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eiri = {
    isNormalUser = true;
    description = "eiri";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # --- Home Manager: Environment ---
  home-manager.users.eiri = { pkgs, ... }: {
    home.stateVersion = "25.11";

    home.packages = with pkgs; [
      # Daily
      vlc
      mpv
      kdePackages.kate
      kdePackages.kcalc
      kdePackages.kclock
      xournalpp
      # Programming
      uv
      python3
    ];

    # Standard XDG Folders (The fix for your music/video folders)
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };

    # Git
    programs.git = {
      enable = true;
      settings.user.name = "Haoting Chen";
      settings.user.email = "u7227871@anu.edu.au";
    };

    # Bash functions
    programs.bash = {
      enable = true;
      # Custom aliases
      shellAliases = {
        me = ''echo "Seneiri!"'';
        python = "python3";
      };
      # Add custom code to the end of .bashrc
      bashrcExtra = ''
        export PATH="$HOME/.local/bin:$PATH"
        echo "Welcome back, eiri!"
      '';
    };
  };

  # ====================== (3) My Settings Block Ends ======================= #

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # ====================== (4) My Setting Block Starts ======================= #

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pciutils
    fastfetch
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # ====================== (4) My Setting Block Ends ======================= #


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # ====================== (5) My Setting Block Starts ======================= #

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Optional but recommended for security
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  services.flatpak.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      kdePackages.fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };

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

  # ====================== (5) My Setting Block Ends ======================= #

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?



  # ====================== (6) My Setting Block Starts ======================= #


  #  === Nvidia Drivers ===

  # Use the stable kernel
  boot.kernelPackages = pkgs.linuxPackages;

  # Enable graphics driver (OpenGL, Vulkan, etc)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  # Tells the Display Server which driver to use for your screen
  # Order matters
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  hardware.nvidia = {

    # Wayland requires kernel mode setting (KMS) to be enabled
    # Tell the Linux Kernel to use "Kernel Mode Setting" for the NVIDIA card.
    # Allows NVIDIA to talk to the amdgpu
    modesetting.enable = true;

    # Use the NVidia open source kernel module
    open = true;

    # Explicitly use the latest driver for 50-series support
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # (Buggy when waking from sleep)
    # Trigger the NVIDIA driver to save the GPU's state during system sleep/suspend
    # powerManagement.enable = true;

    # Allow the NVIDIA GPU to completely power down (0W–1W)
    powerManagement.finegrained = true;

    # Dynamic Boost (20W - 175W range)
    dynamicBoost.enable = true;

    # Common prime setup
    prime = {
      # Bus IDs in the standard decimal format
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";

      # Offload Mode
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };

    # NVIDIA settings GUI
    nvidiaSettings = true;
  };

  # ====================== (6) My Setting Block Ends ======================= #
}
