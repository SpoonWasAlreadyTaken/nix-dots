
{ config, lib, pkgs, blender-bin, ... }:

let
    spoonsert.fractal-theme = pkgs.stdenv.mkDerivation {
        pname = "spoonsert.fractal-theme";
        version = "1.4";
        src = ./config/sddm-theme;

        installPhase = ''
            mkdir -p $out/share/sddm/themes/fractal
            cp -r $src/* $out/share/sddm/themes/fractal/
        '';
    };
in
{
    imports =
        [ 
        ./hardware-configuration.nix
        ];


    /* custom package stuff */
    
    
    /* hardware stuff */
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = true;
        nvidiaSettings = true;
    };


    /* basic system */
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_zen;

    networking.hostName = "spoon";

    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Riga";

    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
    };

    services.xserver.enable = true;
    services.displayManager.sddm = {
        enable = true;

        theme = "fractal";
    };

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };


    users.users.spoon = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
            tree
        ];
    };


    /* services and programs */

    services.udev.extraRules = ''KERNEL=="hidraw*", ATTRS{idVendor}=="31e3", MODE="0666"'';

    nixpkgs.config.allowUnfree = true;


    programs.firefox.enable = true;

    programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    programs.gamescope.enable = true;
    
    programs.gamemode.enable = true;

    programs.zsh.enable = true;
    users.users.spoon.shell = pkgs.zsh;


    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
        };
    };

    services.udisks2.enable = true;
    security.polkit.enable = true;

    services.pulseaudio.enable = false;
    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };


    programs.nix-ld.enable = true;
    
    environment.systemPackages = with pkgs; [
            vim 
            wget
            neovim
            ghostty
            tmux
            git
            quickshell
            rofi
            swaynotificationcenter
            hyprpaper
            hyprpicker
            hyprshot
            hyprlock
            hyprshutdown
            fzf
            clang
            cmake
            gnumake
            gcc
            nil
            luajit
            luarocks
            lua-language-server
            fastfetch
            vlc
            easyeffects
            wootility
            starship
            vesktop
            pulseaudio
            jq    
            wineWow64Packages.staging
            winetricks
            wine64Packages.fonts
            imv 
            krita
            blender-bin.packages.${pkgs.stdenv.hostPlatform.system}.default
            hyprpolkitagent
            ffmpeg
            _7zz
            file
            htop
            clang-tools
            vulkan-tools
            gamescope-wsi
            sfml
            glibc
            zlib


            /* custom */
            spoonsert.fractal-theme

            ];


    fonts.packages = with pkgs; [
        noto-fonts
            noto-fonts-color-emoji
            liberation_ttf
            cascadia-code
            nerd-fonts.caskaydia-mono
            nerd-fonts.jetbrains-mono
            nerd-fonts.caskaydia-cove
            nerd-fonts.hack
            nerd-fonts.iosevka
    ];

    fonts.fontDir.enable = true;



    /* nix specific settings */

    systemd.services.nixos-flake-update = {
        description = "Auto-update flake";
        serviceConfig.Type = "oneshot";
        script = ''
           cd /home/spoon/nixos-dotfiles
           ${pkgs.nix}/bin/nix flake update
        '';
    };
    systemd.timers.nixos-flake-update = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
        };
    };

    system.autoUpgrade.enable = true;
    system.autoUpgrade.dates = "weekly";  
    system.autoUpgrade.persistent = true;
    system.autoUpgrade.flake = "/home/spoon/nixos-dotfiles#spoon";
    system.autoUpgrade.flags = [ "--refresh" "--commit-lock-file" ];

    nix.gc.automatic = true;
    nix.gc.dates = "daily";
    nix.gc.options = "--delete-older-than 3d";
    nix.settings.auto-optimise-store = true;

    programs.git = {
        enable = true;
        config = {
            safe = {
                directory = "/home/spoon/nixos-dotfiles";
            };
        };
    };


    nix.settings.experimental-features = [ "nix-command" "flakes" ];


    system.stateVersion = "26.05";

}

