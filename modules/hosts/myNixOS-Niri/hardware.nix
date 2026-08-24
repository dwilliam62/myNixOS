{ self, inputs, ... }:
{
  flake.nixosModules.myMachineHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports =
      [ (modulesPath + "/profiles/qemu-guest.nix")
      ];

  boot = { 
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c1d1a57f-fe0c-4f81-bbd8-87710f021c99";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/c1d1a57f-fe0c-4f81-bbd8-87710f021c99";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/c1d1a57f-fe0c-4f81-bbd8-87710f021c99";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/.snapshots" =
    { device = "/dev/disk/by-uuid/c1d1a57f-fe0c-4f81-bbd8-87710f021c99";
      fsType = "btrfs";
      options = [ "subvol=@snapshots" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/AC76-90EF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };


  fileSystems."/mnt/nas" =
    { device = "192.168.40.11:/volume1/DiskStation54TB";
      fsType = "nfs";
      options = [ "rw" "bg" "tcp" "_netdev" ];
    };

  swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}

