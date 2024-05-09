# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    inputs.entenvim.homeManagerModules.default
    ./alacritty.nix
    ./theming.nix
    ./development.nix
    ./cli-tools.nix
    ./hyprland.nix
    ./spicetify.nix
    ./neovim.nix
    ./rofi.nix
    ./dunst.nix
    ./zathura.nix
    ./waybar.nix
    ./zoxide.nix
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
      XDG_CURRENT_DESKTOP = "hyprland";
      EDITOR = "nvim";
      # HACK: Fix eclipse crash
      WEBKIT_DISABLE_DMABUF_RENDERER = "1";
    };
  };

  # Enable alacritty
  alacritty.enable = true;

  # Enable dunst
  dunst.enable = true;

  # Enable zathura
  zathura.enable = true;

  # Enable waybar
  waybar.enable = true;

  # Enable zoxide
  zoxide.enable = true;

  # Enable rofi
  rofi.enable = true;

  # Enable XDG Desktop
  xdg.enable = true;
  xdg.mime.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    unstable.obsidian
    keepassxc
    libsecret
    webcord
    jetbrains.idea-ultimate
    openjdk21
  ];

  xdg.desktopEntries.webcord = {
    name = "Discord";
    genericName = "Discord";
    exec = "webcord --enable-features=UseOzonePlatform --ozone-platform=wayland";
    icon = "webcord";
    terminal = false;
    type = "Application";
    categories = ["Network"];
  };

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
