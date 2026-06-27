{...}: {
  flake.homeManagerModules.obsidian = {
    pkgs,
    config,
    ...
  }: {
    xdg.desktopEntries.obsidian = {
      name = "Obsidian";
      exec = "${pkgs.obsidian}/bin/obsidian %u";
      icon = "obsidian";
      mimeType = ["x-scheme-handler/obsidian"];
      type = "Application";
    };
  };
}
