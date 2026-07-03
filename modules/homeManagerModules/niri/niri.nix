{
  lib,
  input,
  ...
}: {
  flake.homeManagerModules.niri = {
    pkgs,
    config,
    ...
  }: {
    options.niri = {
      enable = lib.mkEnableOption "Enable niri";

      keyboardLayout = lib.mkOption {
        type = lib.types.str;
        default = "us(altgr-intl)";
      };
    };

    config = lib.mkIf config.niri.enable {
      home.file.".config/niri/config.kdl" = {
        force = true;
        text =
          lib.readFile ./config.kdl
          + ''
            input {
                keyboard {
                    xkb {
                        layout "${config.niri.keyboardLayout}"
                    }
                    numlock
                }

                touchpad {
                    tap
                    natural-scroll
                }

                mouse {
                    accel-profile "flat"
                    accel-speed 0.5
                }
                focus-follows-mouse
            }
          '';
      };
    };
  };
}
