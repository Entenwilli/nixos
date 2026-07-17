{
  self,
  inputs,
  ...
}: {
  flake.homeManagerModules.common = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.entenvim.homeManagerModules.default
      inputs.base16.homeManagerModule
      {
        scheme = "${inputs.color-schemes}/base24/catppuccin-mocha.yaml";
      }
      self.homeManagerModules.niri
      self.homeManagerModules.browser
      self.homeManagerModules.covers
      self.homeManagerModules.cli-tools
      self.homeManagerModules.codium
      self.homeManagerModules.development
      self.homeManagerModules.discord
      self.homeManagerModules.dunst
      self.homeManagerModules.fastfetch
      self.homeManagerModules.fish
      self.homeManagerModules.hyprland
      self.homeManagerModules.impermanence
      self.homeManagerModules.languages
      self.homeManagerModules.media
      self.homeManagerModules.obsidian
      self.homeManagerModules.office
      self.homeManagerModules.password-manager
      self.homeManagerModules.rofi
      self.homeManagerModules.secrets
      self.homeManagerModules.spotify
      self.homeManagerModules.starship
      self.homeManagerModules.terminal
      self.homeManagerModules.theming
      self.homeManagerModules.university
      self.homeManagerModules.wallpaper-switcher
      self.homeManagerModules.waybar
      self.homeManagerModules.yazi
      self.homeManagerModules.zathura
      self.homeManagerModules.zellij
      self.homeManagerModules.zoxide
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
    dunst.enable = false;

    # Enable zathura
    zathura.enable = true;

    # Enable codium
    codium.enable = true;

    # Enable waybar
    waybar.enable = false;

    # Enable zoxide
    zoxide.enable = true;

    # Enable rofi
    rofi.enable = true;

    # Enable zellij
    zellij.enable = true;

    # Enable fish
    fish.enable = true;

    # Enable hyprland
    hyprland.enable = true;

    niri.enable = true;

    home.packages = [
      pkgs.proton-vpn
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
      pkgs.foliate
      pkgs.wine64Packages.unstableFull
      pkgs.unstable.winetricks
    ];
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
  };
}
