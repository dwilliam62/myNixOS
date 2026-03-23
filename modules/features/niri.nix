{ self, inputs, ... }: { 

  perSystem = { pkgs, ...}: {
   packages.myNiri = inputs.wrapper-modules.wrappers.niri.warp;
     settings = { 
      input.keyboard = { 
       xkb.layout = "us"
      };
      layout.gaps = 5; 
      binds = { 
       "Mod+Return".spawn-sh = lib.getExe pkgs.kitty; 
       "Mod+Q".close-window = null; 
       };
    };
  };

}

