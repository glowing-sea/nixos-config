{ config, pkgs, ... }:

let
  # Use your specific path
  dotfiles = "/home/eiri/Desktop/nixos-config/out-of-store-symlinks";
  createSimlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in

{
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

  # Software
  home.packages = with pkgs; [
    vlc
    mpv
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kclock
    xournalpp
    texliveFull
    # uv
    # python3
  ];

  # VS Code
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    # package = pkgs.vscode-fhs;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Python
      ms-python.python
      ms-python.vscode-pylance
      ms-python.debugpy

      # Jupyter
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
      ms-toolsai.jupyter-keymap
      ms-toolsai.vscode-jupyter-slideshow
      ms-toolsai.vscode-jupyter-cell-tags

      # C++
      ms-vscode.cpptools
      ms-vscode.cpptools-extension-pack
      ms-vscode.cmake-tools

      # AI
      github.copilot
      github.copilot-chat

      # Nix
      mkhl.direnv                 # The direnv connector
      jnoortheen.nix-ide          # Essential for Nix syntax highlighting/flakes

      # Latex
      james-yu.latex-workshop
      # ms-vscode.cpptools
      # Add your specific research tools here
    ];

#     profiles.default.userSettings = {
#       "files.autoSave" = "afterDelay";
#       "update.mode" = "none"; # Diable editor update
#       "extensions.autoUpdate" = false; # no extention update
#       "extensions.autoCheckUpdates" = false; # no extention update
#       # "telemetry.telemetryLevel" = "off";
#       # ... your other research settings
#     };

#   userSettings = {
#     "editor.fontSize" = 14;
#     "workbench.colorTheme" = "Default Dark Modern";
#     "update.mode" = "none"; # Let Nix handle updates
#     };

  };


  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.configFile = {
    "Code/User/settings.json".source = createSimlink "code/settings.json";
    # "kdeglobals".source = createSimlink "kde/kdeglobals";
    # "plasmarc".source = createSimlink "kde/plasmarc";
    # "kglobalshortcutsrc".source = createSimlink "kde/kglobalshortcutsrc";
    # "kwinrc".source = createSimlink "kde/kwinrc";

    # You can add Konsole or other apps here too
    # "konsole".source = createSimlink "konsole";
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
      nix-switch = "sudo nixos-rebuild switch --flake ~/nixos-config#eiri-coffee";
      python = "python3";
      activate-kt = "nix develop ~/nixos-config/python-envs/kt";
      activate-base = "nix develop ~/nixos-config/python-envs/base";
    };
    bashrcExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      echo "Welcome back, eiri!"
    '';
  };
}
