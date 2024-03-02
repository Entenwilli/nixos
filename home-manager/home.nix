# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./alacritty.nix
    ./theming.nix
    ./development.nix
  ];

  # Configure nix package manager
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # Set home and username
  home = {
    username = "felix";
    homeDirectory = "/home/felix";
    sessionVariables = {
      DMENU_BLUETOOTH_LAUNCHER = "rofi";
    };
  };

  # Enable XDG Desktop
  xdg.enable = true;
  xdg.mime.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [ 
    fzf
    ripgrep
    jq
    socat

    unstable.obsidian
    keepassxc
    discord
    lazygit
    jetbrains.idea-ultimate
    openjdk17
    unstable.eww
    unstable.neovim
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Enable cat alternative
  programs.bat.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
