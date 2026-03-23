{ self, inputs, ... }: {

 flake.nixosModules.myMachineConfiguration = { pkgs, lib, ...}: { 
  imports = [ 
   self.nixosModules.myMachineHardware
   self.nixosModules.niri
  ]; 

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    accept-flake-config = true;
  };

  programs = { 
     zsh.enable = true;
     mtr.enable = true;
     neovim = {
  	enable = true;
        defaultEditor = true;
     };
  };
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "z3fold" ];
    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=20"
      "zswap.zpool=z3fold"
    ];
  };

  networking = {
    hostName = "MyNixOS-Niri";
    networkmanager.enable = true;
    firewall.enable = false;
  };

  time.timeZone = "America/New_York";
  console.keyMap = "us";

  users.users.dwilliams = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "input" ];
    initialHashedPassword = "$6$.IYTYtHu3OWt28hg$YsGlhFkoaspMFmVaDWQFvAWRDmzG7vhtCwuuVmGhS7lMDP3RUapuvmMOnEJloQX4RgZs.PFfLepekxZkFhjpL1";
  };

  services.openssh.enable = true;

  boot.loader.grub.enable = false;
  nixpkgs.config.allowUnfree = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  nix.gc = { 
   automatic = true;
   dates = "weekly"; 
   options = "--delete-older-than 7d"; 
  };
  nix.settings.auto-optimise-store = true; 

 services.qemuGuest.enable = true;
 # Ooptional and sometimes breaks setting resolution in VMs
 services.spice-vdagentd.enable = false; 

  system.stateVersion = "26.05";


  environment.systemPackages = with pkgs; [ 
    google-chrome discord-canary vim git ncftp htop btop pciutils btrfs-progs 
    wget curl neovim gnused gawk ripgrep gnugrep findutils coreutils
    bottom luarocks gping kitty rofi zoxide starship eza bat 
    ncdu tree clang zig tmux ghostty 
   ];
 };
}

