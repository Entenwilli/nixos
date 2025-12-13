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
    inputs.impermanence.homeManagerModules.impermanence
    {
      scheme = "${inputs.color-schemes}/base24/catppuccin-mocha.yaml";
    }
    ../media.nix
    ../common.nix
    ../impermanence.nix
    ../wallpaper-switcher.nix
    ../terminal.nix
    ../theming.nix
    ../fish.nix
    ../development.nix
    ../cli-tools.nix
    ../hyprland.nix
    ../spotify.nix
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
    ../coverart.nix
    ../secrets.nix
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

  # Enable impermanence
  impermanence.enable = true;

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
  waybar.enable = false;

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
      name = "DP-3";
      mode = "2560x1440@144";
      position = "0x0";
      scale = 1.0;
      hdr = true;
      sdr_min_luminance = 0.005;
      sdr_max_luminance = 200;
      wallpaper = "/home/felix/pictures/wallpaper/snowy-lake.jpg";
    }
    {
      name = "DP-2";
      mode = "2560x1440@144";
      position = "2560x0";
      scale = 1.0;
      hdr = true;
      sdr_min_luminance = 0.005;
      sdr_max_luminance = 200;
      wallpaper = "/home/felix/pictures/wallpaper/nighttime-in-the-mountains.png";
    }
    {
      name = "HDMI-A-1";
      mode = "2560x1600@60";
      position = "5120x0";
      scale = "1.0";
      sdr_min_luminance = 0.005;
      sdr_max_luminance = 200;
      wallpaper = "/home/felix/pictures/wallpaper/nighttime-in-the-mountains.png";
    }
  ];
  home.packages = [
    inputs.entenshell.packages.${pkgs.stdenv.hostPlatform.system}.entenshell
    pkgs.protonvpn-gui
    (pkgs.writeShellApplication {
      name = "typing";

      text = ''
        value=$(fcitx5-remote -n)

        if [ "$value" == "keyboard-us" ]; then
          hyprctl devices -j | jq -r '.keyboards[] | .layout' | head -n1
        elif [ "$value" == "mozc" ]; then
          echo "jp"
        fi
      '';
    })
    pkgs.jq
  ];
  hyprland.hyprpaper.enable = false;
  wallpaper-switcher.enable = false;
  hyprland.keyboardLayout = "us";

  # Enable starship promt
  starship.enable = true;

  # Enable yazi
  yazi.enable = true;

  # Enable spotify
  spotify.enable = true;

  # Enable Cover Script
  coverart.enable = true;

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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
