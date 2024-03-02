{
  libs,
  pkgs,
  ...
}: {
  # Install required packages 
  home.packages = with pkgs; [
    commitizen
  ];

  # Configure git
  programs.git = {
    enable = true;
    userName = "Felix Schwickerath";
    userEmail = "felix@fschwickerath.de";
  };

  # Configure lazygit
  programs.lazygit = {
    enable = true;
    settings = {
      gui.shortTimeFormat = "15:04:05";
      customCommands = [
        "c" = {
          command = "git cz";
          description = "commit with commitizen";
          context = "files";
          loadingText = "opening commit tool";
          subprocess = true;
        };
      ];
    };
  };

  # Configure commitizen
  home.file.".czrc".text = ''
    {
      "path": "cz-conventional-changelog"
    }
  ''
}
