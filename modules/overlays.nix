{inputs, ...}: {
  flake.overlays = {
    additions = final: _prev: import ../pkgs {pkgs = final;};

    modifications = final: prev: {
      gnome-network-displays-patched = prev.gnome-network-displays.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [prev.gtk3 prev.wpa_supplicant prev.glib-networking prev.gst_all_1.gstreamer prev.gst_all_1.gst-plugins-base prev.gst_all_1.gst-vaapi];
      });
      eclipses.eclipse-modeling = prev.eclipses.eclipse-modeling.overrideAttrs {
        src = prev.fetchurl {
          url = "https://www.eclipse.org/downloads/download.php?r=1&nf=1&file=/technology/epp/downloads/release/2026-06/R/eclipse-modeling-2026-06-R-linux-gtk-x86_64.tar.gz";
          hash = "sha256-jWeFmMGKEJvUAWzUx+b/ErcFBNiwTktpcc86oaxgL3A=";
        };
      };
      xwayland-satellite-updated = prev.xwayland-satellite.overrideAttrs (finalAttrs: prevAttrs: rec {
        cargoHash = "sha256-Saa3SRsQuY6u6pfBGezaEExOt/ReblnrG7pAXjA6Dk8=";
        version = "0.8.2";
        src = prev.fetchFromGitHub {
          owner = "Supreeeme";
          repo = "xwayland-satellite";
          tag = "v${version}";
          hash = "sha256-Mb7jpqnrcYCfNSItIkkHpuR3YxWFxPuIBfcwNKlRBkk=";
        };
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit (finalAttrs) pname src version;
          hash = finalAttrs.cargoHash;
        };
      });
      wine11 = prev.wineWowPackages.stableFull_11.overrideAttrs (old: {
        version = "11.4";
        src = prev.fetchurl {
          url = "https://dl.winehq.org/wine/source/11.x/wine-11.4.tar.xz";
          hash = "sha256-GXCkY4HTvCxE1lHQgzY3Dkme64tT3JPL0c5UT3EV5Zg=";
        };
        staging = prev.fetchFromGitLab {
          domain = "gitlab.winehq.org";
          owner = "wine";
          repo = "wine-staging";
          rev = "v11.4";
          hash = "sha256-m7QrHWaRkoWSdaj4rwuZznjM8mrkxHGEqVSLZTKf4pU=";
        };
      });
    };

    unstable-packages = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };
  };
}
