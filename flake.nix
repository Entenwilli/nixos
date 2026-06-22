{
  description = "Entenwilli's NixOS config";

  nixConfig = {
    abort-on-warn = true;
    allow-import-from-derivation = false;
  };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # NUR
    nur.url = "github:nix-community/nur";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Hardware configuration
    hardware.url = "github:nixos/nixos-hardware";

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # Credential management wth sops
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Neovim Configuration
    entenvim.url = "github:Entenwilli/neovim";
    entenvim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Quickshell
    entenshell.url = "git+ssh://git@github.com/Entenwilli/shell";

    # Color theming
    base16.url = "github:SenchoPens/base16.nix";
    color-schemes.url = "github:tinted-theming/schemes";
    color-schemes.flake = false;

    # Zen Browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    # Helium Browser
    helium-browser.url = "github:oxcl/nix-flake-helium-browser";
    helium-browser.inputs.nixpkgs.follows = "nixpkgs";

    # Hyprpaper flake
    hyprpaper.url = "github:hyprwm/Hyprpaper";

    # Hyprshutdown flake
    hyprshutdown.url = "github:hyprwm/hyprshutdown";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    csp.url = "github:h-banii/clip-studio-paint-nix";

    # Darkly
    # FIXME: Remove when qt5 (currently in keepassxc) is no longer used
    darkly_nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Flake Parts
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Import Tree
    import-tree.url = "github:vic/import-tree";
  };

  outputs = inputs: let
    inherit (inputs.nixpkgs) lib;
    inherit (lib.fileset) toList fileFilter;
    isNixModule = file: file.hasExt "nix" && !lib.hasPrefix "_" file.name;
    importTree = path: toList (fileFilter isNixModule path);
    mkFlake = inputs.flake-parts.lib.mkFlake {inherit inputs;};
  in
    mkFlake {
      imports = [inputs.flake-parts.flakeModules.flakeModules] ++ importTree ./modules;
      systems = [
        "x86_64-linux"
      ];
    };
}
