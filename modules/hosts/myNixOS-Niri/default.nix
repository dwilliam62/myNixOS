{ self, inputs, ...}: {

  flake.nixosConfigurations."PBS3-2TB" = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.myMachineConfiguration
      ];
    };
}

