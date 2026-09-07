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
          # Always present
          timetracking = {
            id = "ad28fe9d-de70-412a-bb80-484ff2f72feb";
            workspace = workspaces.default.id;
            url = "https://time.fschwickerath.de";
            isEssential = true;
            position = 101;
          };
          dashboard = {
            id = "c8de7133-2962-4e73-959e-e6e42c1f9d6a";
            workspace = workspaces.default.id;
            url = "https://dashboard.fschwickerath.de";
            isEssential = true;
            position = 102;
          };
          wanikani = {
            id = "4797778b-04a1-4308-bdc1-97a124494346";
            workspace = workspaces.default.id;
            url = "https://wanikani.com";
            isEssential = true;
            position = 103;
          };

          # Study pins
          illias = {
            id = "017c7063-718e-4ad5-a992-48c6000aba2c";
            workspace = workspaces.study.id;
            url = "https://ilias.studium.kit.edu";
            position = 200;
          };

          # Japanese pins
          asbplayer = {
            id = "83f9961a-a673-4c03-8161-6bb96a045b4a";
            workspace = workspaces.japanese.id;
            url = "https://app.asbplayer.dev";
            position = 300;
          };
          natively = {
            id = "f3586b92-f86c-41c6-8f8d-0f2b31f29c5a";
            workspace = workspaces.japanese.id;
            url = "https://learnnatively.com";
            position = 301;
          };
          wanitrack = {
            id = "3efb7458-81cd-4a97-8f99-f465fad09a1b";
            workspace = workspaces.japanese.id;
            url = "https://wanitrack.com";
            position = 302;
          };
        };
      };
    };
  };
}
