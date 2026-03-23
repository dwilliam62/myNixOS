{ self, inputs, ...}: {

  flake.nixosConfigurations.MyNixOS-Niri = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myMachineConfiguration
      ];
    };
}

