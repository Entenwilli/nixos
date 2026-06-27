{
  self,
  lib,
  inputs,
  ...
}: {
  flake.homeManagerModules.codium = {
    pkgs,
    config,
    ...
  }: {
    options.codium = {
      enable = lib.mkEnableOption "Enable Codium Editor";
    };

    config = lib.mkIf config.codium.enable {
      programs.vscodium = {
        enable = true;
        package = pkgs.vscodium;
        profiles.default = {
          enableExtensionUpdateCheck = false;
          enableUpdateCheck = false;
          extensions = with pkgs.vscode-extensions;
            [
              catppuccin.catppuccin-vsc
              catppuccin.catppuccin-vsc-icons
              ltex-plus.vscode-ltex-plus
              jgclark.vscode-todo-highlight
            ]
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "texlab";
                publisher = "efoerster";
                version = "5.26.0";
                hash = "sha256-7zThla13EuO06W4P2zBnRyodBdpvA16RHB+2drwR8Uc=";
              }
              {
                name = "latex-workshop";
                publisher = "james-yu";
                version = "10.16.1";
                hash = "sha256-QhqBCQjWADmuPK9ryMCoQPWE1pyIeO9XfYvN40ipL0Y=";
              }
            ];
          userSettings = {
            "editor.fontFamily" = "'FiraCode Nerd Font Mono', 'Droid Sans Mono', monospace";
            "workbench.experimental.fontFamily" = "'FiraCode Nerd Font Mono'";
            "editor.fontLigatures" = true;
            "workbench.colorTheme" = "Catppuccin Mocha";
            "workbench.iconTheme" = "catppuccin-mocha";
            "explorer.excludeGitIgnore" = true;
            "editor.minimap.enabled" = false;
            "ltex.java.path" = "${config.programs.java.package}/lib/openjdk";
            "ltex.additionalRules.enablePickyRules" = true;
            "ltex.additionalRules.motherTongue" = "de-DE";
            "latex-workshop.formatting.latex" = "latexindent";
            "texlab.chktex.onOpenAndSave" = false;
            "todohighlight.include" = let
              fileextension = ["js" "jsx" "ts" "tsx" "html" "css" "scss" "txt" "md" "tex" "java"];
            in (map (x: "**/*." + x) fileextension);
            "todohighlight.defaultStyle" = {
              "isWholeLine" = true;
            };
          };
        };
      };

      home.persistence."/persistent".directories = lib.mkIf config.impermanence.enable [
        ".config/VSCodium"
      ];
    };
  };
}
