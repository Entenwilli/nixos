# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  pkgs,
  ...
}: {
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
    ../spicetify.nix
    ../rofi.nix
    ../dunst.nix
    ../zathura.nix
    ../waybar.nix
    ../zoxide.nix
    ../starship.nix
    ../yazi.nix
    ../fastfetch.nix
    ../discord.nix
    ../office.nix
    ../password-manager.nix
    ../university.nix
    ../browser.nix
    ../languages.nix
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
      name = "DP-2";
      settings = "2560x1440@144,2560x0,1";
      wallpaper = "/home/felix/pictures/Wallpaper/snowy-lake.jpg";
    }
    {
      name = "DP-3";
      settings = "2560x1440@144,0x0,1";
      wallpaper = "/home/felix/pictures/Wallpaper/nighttime-in-the-mountains.png";
    }
  ];
  hyprland.hyprpaper.enable = false;
  hyprland.keyboardLayout = "us";

  # Enable starship promt
  starship.enable = true;

  # Enable yazi
  yazi.enable = true;

  # Enable spicetify
  spicetify.enable = true;

  # Enable XDG Desktop
  xdg.enable = true;
  xdg.mime.enable = true;

  # Enable university tools
  university.enable = true;

  # Enable office tools
  office.enable = true;

  # Enable development tools
  development.enable = true;

  # Enable password manager
  password-manager.enable = true;

  # Enable discord
  discord.enable = true;

  # Enable browser
  browser.enable = true;

  # HACK: Allow hardware acceleration in obsidian
  xdg.desktopEntries.obsidian = {
    name = "Obsidian";
    exec = "${pkgs.obsidian}/bin/obsidian --use-vulkan --use-gl=egl --enable-zero-copy --enable-hardware-overlays --enable-features=VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization,VaapiIgnoreDriverChecks --disable-features=UseSkiaRenderer,UseChromeOSDirectVideoDecoder --ignore-gpu-blocklist %u";
    icon = "obsidian";
    mimeType = ["x-scheme-handler/obsidian"];
    type = "Application";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
