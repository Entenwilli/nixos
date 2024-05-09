{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {
    alacritty.enable = lib.mkEnableOption "Enable alacritty";
  };

  config = lib.mkIf config.alacritty.enable {
    home.packages = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode"];})
    ];
    programs.alacritty = {
      enable = true;
      settings = {
        shell.program = "${pkgs.fish}/bin/fish";

        colors.bright = {
          black = "0x414868";
          blue = "0x7aa2f7";
          cyan = "0x7dcfff";
          green = "0x9ece6a";
          magenta = "0xbb9af7";
          red = "0xf7768e";
          white = "0xc0caf5";
          yellow = "0xe0af68";
        };

        colors.normal = {
          black = "0x15161e";
          blue = "0x7aa2f7";
          cyan = "0x7dcfff";
          green = "0x9ece6a";
          magenta = "0xbb9af7";
          red = "0xf7768e";
          white = "0xa9b1d6";
          yellow = "0xe0af68";
        };

        colors.primary = {
          background = "0x1a1b26";
          foreground = "0xc0caf5";
        };

        colors.indexed_colors = [
          {
            index = 16;
            color = "0xff9e64";
          }
          {
            index = 17;
            color = "0xdb4b4b";
          }
        ];

        font.size = 14.0;

        font.normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        font.bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        font.italic = {
          family = "FiraCode Nerd Font";
          style = "Italic";
        };
        font.bold_italic = {
          family = "FiraCode Nerd Font";
          style = "Bold Italic";
        };
      };
    };
  };
}
