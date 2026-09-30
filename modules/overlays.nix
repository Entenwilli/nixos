{inputs, ...}: {
  flake.overlays = {
    additions = final: _prev: import ../pkgs {pkgs = final;};

    modifications = final: prev: {
      gnome-network-displays-patched = prev.gnome-network-displays.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [prev.gtk3 prev.wpa_supplicant prev.glib-networking prev.gst_all_1.gstreamer prev.gst_all_1.gst-plugins-base prev.gst_all_1.gst-vaapi];
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
