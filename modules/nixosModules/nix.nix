{...}: {
  flake.nixosModules.nix = {
    pkgs,
    config,
    ...
  }: {
    sops.secrets."github-token-desktop" = {
      owner = "felix";
    };
    nix.extraOptions = ''
      !include ${config.sops.secrets."github-token-desktop".path}
    '';
  };
}
