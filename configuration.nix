
{ config, lib, pkgs, ... }:

{
    imports =
        [ 
        ./hardware-configuration.nix
        ];


    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        open = true;
        nvidiaSettings = true;
    };


    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "spoon";

    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Riga";

    services.pulseaudio.enable = false;
    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };


    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
    };
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;

    users.users.spoon = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        packages = with pkgs; [
            tree
        ];
    };

    nixpkgs.config.allowUnfree = true;

    programs.firefox.enable = true;
    programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

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
            nil
            luajit
            luarocks
            lua-language-server
            fastfetch
            kdePackages.dolphin
            vlc
            easyeffects
            wootility
            starship
            vesktop
            pulseaudio
            jq
            kdePackages.polkit-kde-agent-1
            ];

    fonts.packages = with pkgs; [
        noto-fonts
            noto-fonts-color-emoji
            liberation_ttf
            nerd-fonts.caskaydia-mono
            nerd-fonts.jetbrains-mono
            nerd-fonts.caskaydia-cove
            cascadia-code
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];


    system.stateVersion = "26.05";

}

