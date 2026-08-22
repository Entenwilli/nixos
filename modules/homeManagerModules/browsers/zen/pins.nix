{
  inputs,
  lib,
  ...
}: {
  flake.homeManagerModules.zen-browser-pins = {
    pkgs,
    config,
    ...
  }: {
    config = lib.mkIf config.zen-browser.enable {
      programs.zen-browser.profiles.default = {
        pinsForce = true;
        pins = let
          workspaces = config.programs.zen-browser.profiles.default.spaces;
        in {
          "Timetracking" = {
            id = "ad28fe9d-de70-412a-bb80-484ff2f72feb";
            workspace = workspaces.Default.id;
            url = "https://time.fschwickerath.de";
            isEssential = true;
            position = 101;
          };
          "Dashboard" = {
            id = "c8de7133-2962-4e73-959e-e6e42c1f9d6a";
            workspace = workspaces.Default.id;
            url = "https://dashboard.fschwickerath.de";
            isEssential = true;
            position = 102;
          };
          "Wanikani" = {
            id = "4797778b-04a1-4308-bdc1-97a124494346";
            workspace = workspaces.Default.id;
            url = "https://wanikani.com";
            isEssential = true;
            position = 103;
          };
          "Illias" = {
            id = "017c7063-718e-4ad5-a992-48c6000aba2c";
            workspace = workspaces."Study".id;
            url = "https://ilias.studium.kit.edu";
            position = 200;
          };
        };
      };
    };
  };
}
