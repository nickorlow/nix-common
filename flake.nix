{
  description = "Common NixOS configuration for all machines";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: 
  let
    tmuxConf = ./tmux.conf;
    zshrcConf = ./zshrc.conf;
    commonUserConfig = {pkgs, ...}: {
          home.packages = [ pkgs.zsh pkgs.cowsay ];
          home.stateVersion = "24.05";

          programs.zsh.enable = true;
          programs.zsh.initExtra =  ''
            source /etc/.zshrc.conf
          '';
    };
  in 
  {
    config = [
      home-manager.nixosModules.home-manager
      ({pkgs, ...}: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        security.sudo.wheelNeedsPassword = false;

        environment.systemPackages = [ pkgs.tmux pkgs.htop pkgs.neovim pkgs.watch pkgs.dig ];
  
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
        services.openssh.settings.PasswordAuthentication = true;

        environment.etc.".tmux.conf" = {
            source = tmuxConf;
            mode = "0644";
        };
        
        environment.etc.".zshrc.conf" = {
            source = zshrcConf;
            mode = "0644";
        };

        programs.tmux = {
            enable = true;
            extraConfig = ''
                source-file /etc/.tmux.conf
            '';
        };

        users.users.nickorlow = {
          isNormalUser  = true;
          home  = "/home/nickorlow";
          description  = "Nicholas Orlowsky";
          extraGroups  = [ "wheel" "networkmanager" ];
          openssh.authorizedKeys.keys  = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH6r89jWRUP8cgIPH+UdC3SmzgPqtu4RtvHgBISA1OiT nickorlow@wireless-10-146-46-168.public.utexas.edu" ];
        };

        programs.zsh.enable = true;
        users.defaultUserShell=pkgs.zsh; 

        home-manager.users = {
            nickorlow = commonUserConfig;
            root = commonUserConfig;
        };
      })
    ];
  };
}
