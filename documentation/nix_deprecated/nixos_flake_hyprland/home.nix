{ pkgs, ... }: {
  home.username = "eiri";
  home.homeDirectory = "/home/eiri";
  home.stateVersion = "25.11";

  # The "Tony-style" out-of-store symlink
  # This lets you edit files in ~/nixos-config/config and see changes instantly
  # home.file.".config".source = ./config;

  home.packages = with pkgs; [
    # Applications
    mpv vlc xournalpp firefox
    
    # Hyprland Needs
    grim # screenshot
    slurp # region selector 
    wl-clipboard # clipboard
    # rofi-wayland # App launcher
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      nvidia-run = "nvidia-offload";
      hypr = "start-hyprland";
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#eiri-coffee";
    };
    # profileExtra = ''
      # if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
        # exec hyprland
      # fi
    # '';
  };  

  programs.git = {
    enable = true;
    settings.user.name = "Haoting Chen";
    settings.user.email = "u7227871@anu.edu.au";
  };
}
