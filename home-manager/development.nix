{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  options = {
    development.enable = lib.mkEnableOption "Enable development tools";
  };

  config = lib.mkIf config.development.enable {
    # Install required packages
    home.packages = with pkgs; [
      cz-cli
      yarn
      gnumake
      libgcc
      cmake
      llvmPackages_latest.lldb
      valgrind
      bacon
      clippy
      jetbrains.rust-rover
      texliveFull
      cargo
      rustc
      openjdk17
      jetbrains.idea-ultimate
      neovide
      inputs.pwndbg.packages.${pkgs.system}.pwndbg
    ];

    # Configure git
    programs.git = {
      enable = true;
      userName = "Felix Schwickerath";
      userEmail = "felix@fschwickerath.de";

      signing.format = "ssh";
      signing.key = "~/.ssh/sign_default.pub";
      signing.signByDefault = true;
      extraConfig = {
        init.defaultBranch = "main";
        url = {
          "git@github.com:" = {
            insteadOf = ["https://github.com/" "gh:" "github:"];
          };
        };
      };
    };

    # Configure lazygit
    programs.lazygit = {
      enable = true;
      settings = {
        gui.nerdFontsVersion = "3";
        gui.shortTimeFormat = "15:04:05";
        customCommands = [
          {
            key = "c";
            command = "git cz";
            description = "commit with commitizen";
            context = "files";
            loadingText = "opening commit tool";
            output = "terminal";
          }
        ];
      };
    };

    # Configure commitizen
    home.file.".czrc".text = ''
      {
        "path": "cz-conventional-changelog"
      }
    '';
  };
}
