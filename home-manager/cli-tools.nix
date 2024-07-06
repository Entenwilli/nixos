{pkgs, ...}: {
  # Install cli packages
  home.packages = with pkgs; [
    fzf
    ripgrep
    jq
    socat
    fd
  ];

  # Enable cat alternative
  programs.bat.enable = true;

  # Enable process monitor
  programs.btop.enable = true;
}
