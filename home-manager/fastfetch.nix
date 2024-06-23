{
  lib,
  config,
  ...
}: {
  options = {
    fastfetch.enable = lib.mkEnableOption "Enable fastfetch";
  };

  config = lib.mkIf config.fastfetch.enable {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = ../resources/nix.png;
          type = "kitty-direct";
          padding = {
            top = 2;
          };
          width = 30;
          height = 15;
        };
        display = {
          color = {
            separator = "blue";
          };
          separator = " | ";
        };

        modules = [
          {
            type = "kernel";
            key = "    NixOS   ";
            keyColor = "cyan";
          }
          {
            type = "custom";
            format = ">-----------<+>------------------------------------------<";
            outputColor = "separator";
          }
          {
            type = "uptime";
            key = "   Uptime   ";
            keyColor = "green";
          }
          {
            type = "shell";
            key = "   Shell    ";
            keyColor = "green";
          }
          {
            type = "terminal";
            key = "   Terminal ";
            keyColor = "green";
          }
          {
            type = "terminalfont";
            key = "   Font     ";
            keyColor = "green";
          }
          {
            type = "packages";
            key = "   Packages ";
            keyColor = "green";
          }
          {
            type = "localip";
            key = "   Local IP ";
            keyColor = "green";
          }
          {
            type = "custom";
            format = ">-----------<+>------------------------------------------<";
            outputColor = "separator";
          }
          {
            type = "display";
            key = "   Display  ";
            keyColor = "cyan";
          }
          {
            type = "cpu";
            key = "   CPU      ";
            keyColor = "cyan";
          }
          {
            type = "gpu";
            key = "   GPU      ";
            keyColor = "cyan";
          }
          {
            type = "memory";
            key = "   RAM      ";
            keyColor = "cyan";
          }
          {
            type = "swap";
            key = "   SWAP     ";
            keyColor = "cyan";
          }
          {
            type = "disk";
            key = "   Disk     ";
            keyColor = "cyan";
          }
          {
            type = "battery";
            key = "   Battery  ";
            keyColor = "cyan";
          }
          {
            type = "custom";
            format = ">-----------<+>------------------------------------------<";
            outputColor = "separator";
          }
          "break"
          {
            type = "colors";
            paddingLeft = 15;
          }
        ];
      };
    };
  };
}
