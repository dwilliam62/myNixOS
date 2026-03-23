{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

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

  environment.systemPackages = with pkgs; [
    git ncftp htop btop pciutils btrfs-progs wget curl
    neovim gnused gawk ripgrep gnugrep findutils coreutils
    bottom luarocks gping kitty rofi zoxide starship eza bat 
    ncdu tree clang zig tmux 
  ];

  programs = { 
     zsh.enable = true;
     mtr.enable = true;
     neovim = {
  	enable = true;
        defaultEditor = true;
     };
  };

  services.openssh.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    accept-flake-config = true;
  };

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


  system.stateVersion = "25.11";
}
