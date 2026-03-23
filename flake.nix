{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules/parts.nix
        ./modules/hosts/myNixOS-Niri/default.nix
        ./modules/hosts/myNixOS-Niri/configuration.nix
        ./modules/hosts/myNixOS-Niri/hardware.nix
        ./modules/features/niri.nix
      ];
    };
}
