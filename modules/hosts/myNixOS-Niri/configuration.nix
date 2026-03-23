{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.myMachineConfiguration = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
    ];

    environment.etc."xdg/rofi/legacy.config.rasi".text = ''
      @theme "/dev/null"

      * {
        /* VM palette fast-match */
        bg:            #282936;
        bg-alt:        #3a3c4e;
        fg:            #f7f7fb;
        acc:           #00f769;  /* bright green */
        cyan:          #62d6e8;
        purple:        #b45bcf;
        yellow:        #ebff87;
        pink:          #ea51b2;
        alt:           #a1efe4;

        background-color: @bg;
        text-color: @fg;
        font: "JetBrainsMono Nerd Font 12";
      }

      configuration {
        modi:                 "run,filebrowser,drun";
        show-icons:           true;
        icon-theme:           "Papirus";
        location:             0;
        drun-display-format:  "{icon} {name}";
        display-drun:         "   Apps ";
        display-run:          "   Run ";
        display-filebrowser:  "   File ";
      }

      window {
        width: 45%;
        transparency: "real";
        orientation: vertical;
        border: 2px;
        border-color: @acc;
        border-radius: 10px;
        background-color: @bg;
        background-image: url("~/.config/rofi/legacy-rofi.jpg", width);
      }

      mainbox {
        children: [ inputbar, listview, mode-switcher ];
        background-color: @bg;        /* solid background for content area */
        margin: 200 0 0 0;            /* push content below banner */
        padding: 0 12 12 12;
      }

      element {
        padding: 8 14;
        text-color: @fg;
        border-radius: 5px;
      }
      element selected {
        text-color: @bg-alt;
        background-color: @cyan;
      }
      element-text { background-color: inherit; text-color: inherit; }
      element-icon { size: 24px; background-color: inherit; padding: 0 6 0 0; alignment: vertical; }

      listview {
        columns: 2;
        lines: 9;
        padding: 8 0;
        fixed-height: true;
        fixed-columns: true;
        fixed-lines: true;
        border: 0 10 6 10;
      }

      entry {
        text-color: @fg;
        padding: 12 16 12 16;  /* symmetrical vertical padding, comfortable horizontal */
        margin: 0;             /* remove negative right margin that can offset content */
      }

      inputbar {
        background-color: @bg-alt;    /* ensure it sits on solid background, not image */
        padding: 12 12 12 12;         /* balanced vertical padding */
        margin: 0 0 12 0;             /* add space below the search field */
      }

      prompt {
        text-color: @purple;
        padding: 12 16 12 16;  /* symmetrical vertical padding to match entry */
        margin: 0;             /* remove negative right margin */
      }

      mode-switcher { border-color: @acc; spacing: 0; }


      button { padding: 10px; background-color: @bg; text-color: #ff3b3b; }
      button selected { background-color: @bg; text-color: @acc; }

      message { background-color: @bg; margin: 2px; padding: 2px; border-radius: 5px; }
      textbox { padding: 6px; margin: 20px 0 0 20px; text-color: @acc; background-color: @bg; }
    '';
    environment.etc."xdg/rofi/legacy-rofi.jpg".source = ../../features/rofi/legacy-rofi.jpg;

    nix.settings = {
      experimental-features = ["nix-command" "flakes"];
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
      kernelModules = ["z3fold"];
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
      extraGroups = ["wheel" "networkmanager" "input"];
      initialHashedPassword = "$6$.IYTYtHu3OWt28hg$YsGlhFkoaspMFmVaDWQFvAWRDmzG7vhtCwuuVmGhS7lMDP3RUapuvmMOnEJloQX4RgZs.PFfLepekxZkFhjpL1";
    };

    services.openssh.enable = true;
    services.displayManager.ly.enable = true;
    services.tumbler.enable = true;

    systemd.tmpfiles.rules = [
      "d /home/dwilliams/.config/niri 0700 dwilliams users - -"
      "L+ /home/dwilliams/.config/niri/config.kdl - - - - /etc/xdg/niri/config.kdl"
      "d /home/dwilliams/.config/rofi 0700 dwilliams users - -"
      "L+ /home/dwilliams/.config/rofi/legacy.config.rasi - - - - /etc/xdg/rofi/legacy.config.rasi"
      "L+ /home/dwilliams/.config/rofi/legacy-rofi.jpg - - - - /etc/xdg/rofi/legacy-rofi.jpg"
    ];

    environment.sessionVariables = {
      GTK_THEME = "Adwaita-dark";
      GTK_APPLICATION_PREFER_DARK_THEME = "1";
    };

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
      google-chrome
      discord-canary
      fastfetch
      onefetch
      waypaper
      swww
      swaybg
      git
      ncftp
      htop
      btop
      pciutils
      btrfs-progs
      nwg-look
      wget
      curl
      neovim
      gnused
      gawk
      ripgrep
      gnugrep
      findutils
      coreutils
      bottom
      luarocks
      gping
      kitty
      rofi
      zoxide
      starship
      eza
      bat
      ncdu
      tree
      clang
      zig
      tmux
      ghostty
      alacritty
      rofi
      (writeShellScriptBin "rofi-legacy.menu" ''
        rofi -config ~/.config/rofi/legacy.config.rasi -show drun
      '')
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.thunar-media-tags-plugin
      xfce.tumbler
    ];
  };
}
