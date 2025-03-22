# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{inputs, ...}: {
  # You can import other home-manager modules here
  imports = [
    inputs.entenvim.homeManagerModules.default
    inputs.base16.homeManagerModule
    {
      scheme = "${inputs.color-schemes}/base24/catppuccin-mocha.yaml";
    }
    ../terminal.nix
    ../theming.nix
    ../fish.nix
    ../development.nix
    ../cli-tools.nix
    ../hyprland.nix
    ../rofi.nix
    ../dunst.nix
    ../zathura.nix
    ../waybar.nix
    ../zoxide.nix
    ../starship.nix
    ../yazi.nix
    ../fastfetch.nix
    ../discord.nix
    ../password-manager.nix
    ../university.nix
    ../office.nix
    ../spicetify.nix
    ../browser.nix
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Set home and username
  home = {
    username = "felix";
    homeDirectory = "/home/felix";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # Enable gtk and qt theming
  theming.enable = true;

  # Enable cli-tools
  cli-tools.enable = true;

  # Enable development tools
  development.enable = true;

  # Enable fastfetch
  fastfetch.enable = true;

  # Enable terminal
  terminal.enable = true;

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

  # Enable fish
  fish.enable = true;

  # Enable hyprland
  hyprland.enable = true;
  hyprland.monitors = [
    {
      name = "eDP-1";
      settings = "1920x1200@60,0x0,1";
      wallpaper = "/home/felix/pictures/Wallpaper/tom-vining.jpg";
    }
  ];
  hyprland.keyboardLayout = "de";

  # Enable starship prompt
  starship.enable = true;

  # Enable yazi
  yazi.enable = true;

  # Enable XDG Desktop
  xdg.enable = true;
  xdg.mime.enable = true;

  # Enable discord
  discord.enable = true;

  # Enable password manager
  password-manager.enable = true;

  # Enable univerisity tools
  university.enable = true;

  # Enable office tools
  office.enable = true;

  # Enable spicetify, a spotify client
  spicetify.enable = true;

  # Enable browser
  browser.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
