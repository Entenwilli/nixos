# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{pkgs, ...}: {
  eclipse-dfa = pkgs.callPackage ./eclipse-dfa {};
  wonderdraft = pkgs.callPackage ./wonderdraft {};
}
