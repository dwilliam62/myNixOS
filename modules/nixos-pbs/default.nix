{ inputs, ... }:
{
  flake.nixosModules.nixos-pbs = { ... }: {
    imports = [
      inputs.pbs.nixosModules.proxmox-backup-server
    ];

    nixpkgs.overlays = [
      inputs.pbs.overlays.default
    ];

    nix.settings = {
      substituters = [ "https://awildleon-nixos-pbs.cachix.org" ];
      trusted-public-keys = [
        "awildleon-nixos-pbs.cachix.org-1:4kEEBSONGJ0F7Ita/3ZRcTWaR6M7YHXhltJaoEYl3ew="
      ];
    };
  };
}
