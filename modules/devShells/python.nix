{self, ...}: {
  perSystem = {pkgs, ...}: {
    devShells.python = pkgs.mkShell {
      packages = let
        packageOverrides = pkgs.callPackage ./_python-packages.nix {};
        python = pkgs.python312.override {inherit packageOverrides;};
      in [
        (python.withPackages (p:
          with p; [
            gymnasium
            ipykernel
            jupyter
            matplotlib
            numpy
            pandas
            pillow
            pylatexenc
            qiskit
            qubovert
            requests
            scipy
            stable-baselines3
            sympy
            torch
            torchvision

            # REDACTED
          ]))
      ];
    };
  };
}
