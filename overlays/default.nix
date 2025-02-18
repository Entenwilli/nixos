# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # FIXME: This is currently not required, as hyprland should work correctly!
    # hyprland-patched = let
    #   libinput = prev.libinput.overrideAttrs (self: {
    #     name = "libinput";
    #     version = "1.26.0";
    #     src = final.fetchFromGitLab {
    #       domain = "gitlab.freedesktop.org";
    #       owner = "libinput";
    #       repo = "libinput";
    #       rev = self.version;
    #       hash = "sha256-mlxw4OUjaAdgRLFfPKMZDMOWosW9yKAkzDccwuLGCwQ=";
    #     };
    #   });
    # in
    #   inputs.hyprland.packages.${prev.system}.hyprland.override {
    #     libinput = libinput;
    #     aquamarine = inputs.hyprland.inputs.aquamarine.packages.${prev.system}.aquamarine.override {
    #       libinput = libinput;
    #     };
    #     wayland = final.unstable.wayland;
    #     wayland-scanner = final.unstable.wayland-scanner;
    #     wayland-protocols = final.unstable.wayland-protocols;
    #   };
    # xdg-desktop-portal-hyprland-patched = inputs.hyprland.packages.${prev.system}.xdg-desktop-portal-hyprland.override {
    #   pipewire = final.unstable.pipewire;
    # };
    gnome-network-displays-patched = prev.gnome-network-displays.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [prev.gtk3 prev.wpa_supplicant prev.glib-networking prev.gst_all_1.gstreamer prev.gst_all_1.gst-plugins-base prev.gst_all_1.gst-vaapi];
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
