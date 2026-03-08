# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network
  networking.hostName = "eiri-coffee";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  # Hyperland
  services.getty.autologinUser = "eiri";
  programs.hyprland = {
    enable = true;
    # withUWSM = true; # systemd wrapper of wayland
    xwayland.enable = true;
  };
  
  # Allow screen sharing and file picker
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-hyprland 
      pkgs.xdg-desktop-portal-gtk 
    ];
    config.common.default = "*"; # Tells portals to use available backends for everything
  };

  # Nvidia Settings
  nixpkgs.config.allowUnfree = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
      offload = { enable = true; enableOffloadCmd = true; };
    };
  };

  # Audio
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Essential System Tools
  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    # Core
    git
    vim
    wget
    foot # fallback standardlone terminal
    kitty # GPU-accerlated terminal
    
    # Hyprland Ecosystem
    waybar # customisable bar at the top of the screen
    hyprpaper # simple wallpaper
    swww # animated wallpaper
    mako # notification
    libnotify # notification bridge
    
    # System Monitors
    nvtopPackages.full # GPU monitor
    nvitop # Python-based GPU monitor (great for ML)    
    fastfetch    
    
    # Search
    fzf # fuzzy finder
    ripgrep # alternative to grep
  ];
  
  # User
  users.users.eiri = {
    isNormalUser = true;
    description = "eiri";
    extraGroups = [ 
      "networkmanager" # Switch network without sudo
      "wheel"
      "video" # give user direct access to video hardware devices or webcam
    ];
  };

  # Locale
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";
  services.xserver.xkb = { layout = "au"; variant = ""; }; # gloabl keyboard default 

  # Chinese Input
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [ kdePackages.fcitx5-chinese-addons fcitx5-gtk ];
  };
  
  # Fonts
  fonts.packages = with pkgs; [ 
    noto-fonts # Base Latin fonts
    noto-fonts-cjk-sans # Chinese/Japanese/Korean
    source-han-sans
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" "Noto Serif CJK SC" ];
    sansSerif = [ "Noto Sans" "Noto Sans CJK SC" ];
    monospace = [ "JetBrainsMono Nerd Font" ];
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

