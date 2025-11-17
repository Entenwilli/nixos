{pkgs, ...}: {
  nixpkgs.config.rocmSupport = true;

  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.unstable.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  hardware.graphics.extraPackages = with pkgs.unstable; [
    rocmPackages.clr.icd
  ];
}
