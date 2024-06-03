{pkgs, ...}: {
  environment.systemPackages = [
    # Install the wrapper into the system
    (let
      packages = with pkgs; [
        clang-tools
        clangStdenv
        cmake
        fish
      ];
    in
      pkgs.runCommand "effprog" {
        # Dependencies that should exist in the runtime environment
        buildInputs = packages;
        # Dependencies that should only exist in the build environment
        nativeBuildInputs = [pkgs.makeWrapper];
      } ''
        mkdir -p $out/bin/
        ln -s ${pkgs.fish}/bin/fish $out/bin/effprog
        wrapProgram $out/bin/effprog --prefix PATH : ${pkgs.lib.makeBinPath packages}
      '')
  ];
}
