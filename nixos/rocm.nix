{pkgs, ...}: {
  nixpkgs.config.rocmSupport = true;

  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
}
