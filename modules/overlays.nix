{inputs, ...}: {
  flake.overlays = {
    additions = final: _prev: import ../pkgs {pkgs = final;};

    modifications = final: prev: {
      gnome-network-displays-patched = prev.gnome-network-displays.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [prev.gtk3 prev.wpa_supplicant prev.glib-networking prev.gst_all_1.gstreamer prev.gst_all_1.gst-plugins-base prev.gst_all_1.gst-vaapi];
      });
      vesktop = prev.vesktop.override {
        pnpm_10_29_2 = final.pnpm_10;
      };
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

    #FIXME: Remove darkly-qt5 and flake input when qt5 is no longer used
    darkly = final: _prev: {
      darkly_nixpkgs = import inputs.darkly_nixpkgs {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    };
  };
}
