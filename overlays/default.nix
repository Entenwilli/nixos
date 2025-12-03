# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    gnome-network-displays-patched = prev.gnome-network-displays.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [prev.gtk3 prev.wpa_supplicant prev.glib-networking prev.gst_all_1.gstreamer prev.gst_all_1.gst-plugins-base prev.gst_all_1.gst-vaapi];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
