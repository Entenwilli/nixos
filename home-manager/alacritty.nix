{
  lib, pkgs, ...
}: {
  home.packages = with pkgs; [
    nerdfonts
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

      font.size = 14.0;

      font.normal = {
        family = "FiraCode Nerd Font";
        style = "Regular";
      };
    };
  };
}
