{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.zen-browser-spaces = {
    pkgs,
    config,
    ...
  }: {
    config = lib.mkIf config.zen-browser.enable {
      programs.zen-browser.profiles.default = {
        spacesForce = true;
        spaces = {
          default = {
            name = "Default";
            id = "79106985-252e-431b-8b2f-d080c4ddc8d3";
            position = 1000;
            icon = "📂";
          };
          study = {
            name = "Study";
            id = "32cf9052-c37c-4e61-bcb1-757b7e116213";
            position = 2000;
            icon = "📚";
          };
          japanese = {
            name = "Japanese";
            id = "95de3d8e-23f9-4131-af7e-1ff0753b630d";
            position = 3000;
            icon = "🇯🇵";
          };
          dnd = {
            name = "D&D";
            id = "418596af-98cd-4f8e-a205-c338b2b6428d";
            position = 4000;
            icon = "🐉";
          };
        };
      };
    };
  };
}
