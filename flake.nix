{
  description = "Entenwilli's NixOS config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Impermanence
    impermanence.url = "github:nix-community/impermanence";

    # Hardware configuration
    hardware.url = "github:nixos/nixos-hardware";

    # Flake utils
    flake-utils.url = "github:numtide/flake-utils";

    # Credential management wth sops
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Neovim Configuration
    entenvim.url = "github:Entenwilli/neovim";
    entenvim.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Color theming
    base16.url = "github:SenchoPens/base16.nix";
    color-schemes.url = "github:tinted-theming/schemes";
    color-schemes.flake = false;

    # Zen Browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    # Pwndbg
    pwndbg.url = "github:pwndbg/pwndbg";

    # Hyprland flake
    hyprland.url = "github:hyprwm/Hyprland";

    # Spicetify
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = {
    self,
    nixpkgs,
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
            inputs.impermanence.nixosModules.impermanence
            inputs.base16.nixosModule
            {
              scheme = "${inputs.color-schemes}/base24/catppuccin-mocha.yaml";
            }
            ./nixos/configurations/desktop.nix
            inputs.sops-nix.nixosModules.sops
            inputs.entenvim.nixosModules.neovim
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
              home-manager.users.felix = import ./home-manager/homes/desktop.nix;
            }
          ];
        };
      nixos-laptop = let
        specialArgs = {inherit inputs outputs;};
      in
        nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs;
          modules = [
            inputs.impermanence.nixosModules.impermanence
            inputs.base16.nixosModule
            {
              scheme = "${inputs.color-schemes}/base24/catppuccin-mocha.yaml";
            }
            ./nixos/configurations/laptop.nix
            inputs.sops-nix.nixosModules.sops
            inputs.entenvim.nixosModules.neovim
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
              home-manager.users.felix = import ./home-manager/homes/laptop.nix;
            }
          ];
        };
    };
  };
}
