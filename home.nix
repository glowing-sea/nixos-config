{ pkgs, ... }: {
  home.username = "eiri";
  home.homeDirectory = "/home/eiri";
  home.stateVersion = "25.11";

  # This is the "Tony-style" link to your dotfiles
  # Anything you put in ~/nixos-config/config will appear in ~/.config
  # This links ~/nixos-config/config/ to ~/.config/
  # but does it safely by merging rather than replacing the whole folder
  # home.file.".config" = {
    # source = ./config;
    # recursive = true;
  # };

  home.packages = with pkgs; [
    vlc
    mpv
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kclock
    xournalpp
    # uv
    # python3
  ];

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Haoting Chen";
        email = "u7227871@anu.edu.au";
      };
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      me = "echo 'Seneiri!'";
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-configs#eiri-coffee";
      python = "python3";
    };
    bashrcExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      echo "Welcome back, eiri!"
    '';
  };
}
