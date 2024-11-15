{
  description = "Entenwilli's NixOS config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware configuration
    hardware.url = "github:nixos/nixos-hardware";

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # Credential management wth sops
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs"; # This could also be unstable
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";

    # Neovim Configuration
    entenvim.url = "github:Entenwilli/neovim";
    entenvim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Grub bootloader theme
    grub2-themes.url = "github:vinceliuice/grub2-themes";

    # Color theming
    nix-colors.url = "github:misterio77/nix-colors";

    # Hyprland flake
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # NixOS configuration entrypoint
    nixosConfigurations = {
      nixos-desktop = let
        specialArgs = {inherit inputs outputs;};
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs;
          modules = [
            ./nixos/configurations/desktop.nix
            inputs.sops-nix.nixosModules.sops
            inputs.entenvim.nixosModules.neovim
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.felix = import ./home-manager/homes/desktop.nix;
            }
            inputs.grub2-themes.nixosModules.default
          ];
        };
      nixos-laptop = let
        specialArgs = {inherit inputs outputs;};
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs;
          modules = [
            ./nixos/configurations/laptop.nix
            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.felix = import ./home-manager/homes/laptop.nix;
            }
            inputs.grub2-themes.nixosModules.default
          ];
        };
    };
  };
}
