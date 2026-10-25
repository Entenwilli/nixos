{inputs, ...}: {
  flake.overlays = {
    additions = final: prev:
      import ../pkgs {
        pkgs = final;
        inherit prev;
      }
      // {
        entenshell = inputs.entenshell.packages.${final.stdenv.hostPlatform.system}.entenshell;
      };

    modifications = final: prev: {
      gnome-network-displays-patched = prev.gnome-network-displays.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [prev.gtk3 prev.wpa_supplicant prev.glib-networking prev.gst_all_1.gstreamer prev.gst_all_1.gst-plugins-base prev.gst_all_1.gst-vaapi];
      });

      mecab = prev.mecab.overrideAttrs (_: {
        postInstall = ''
          mkdir -p $out/lib/mecab/dic
          ln -s ${prev.mecab-ipadic-neologd} $out/lib/mecab/dic/ipadic
        '';
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
