{ config, pkgs, ... }:

let
	dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
	create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
	configs = {
		nvim = "nvim";
		hypr = "hypr";
		ghostty = "ghostty";
		rofi = "rofi";
		swaync = "swaync";
		tmux = "tmux";
		starship = "starship";
	};
in

{
    /* Basic user */
	home.username = "spoon";
	home.homeDirectory = "/home/spoon";
	home.stateVersion = "26.05";

    /* Shell */

	programs.bash = {
		enable = true;
	};

	programs.zsh = {
		enable = true;
		enableCompletion = true;
		autosuggestion.enable = true;

        defaultKeymap = "viins";

        initContent = ''
            export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

            bindkey -v

            bindkey -M viins '^?' backward-delete-char
            bindkey -M viins '^H' backward-delete-char

            function zle-line-init {
                zle reset-prompt
            }

            zle -N zle-line-init
        '';
	};
    
    programs.starship = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
    };

	home.sessionVariables = {
		EDITOR = "nvim";
        TERMINAL = "ghostty";
	};

    /* ricing */

    gtk = {
        enable = true;
        iconTheme = {
            name = "Papirus";
            package = pkgs.papirus-icon-theme;
        };

        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };

        gtk4.extraConfig = {
            gtk-application-prefer-dark-theme = 1;
        };
    };

    
    /* dots and stuff */
	programs.git = {
		enable = true;
		settings.user.name = "SpoonWasAlreadyTaken";
		settings.user.email = "laserpyoro@gmail.com";
	};


	xdg.configFile = builtins.mapAttrs (name: subpath: {
		source = create_symlink "${dotfiles}/${subpath}";
		recursive = true;
	}) configs;

    home.file.".local/share/icons/Sweet-hyprcursors" = {
        source = ./theming/Sweet-hyprcursors;
    };

    /* home packages */

    home.packages = with pkgs; [
        tree-sitter
        ffmpegthumbnailer
        poppler
        fd
        ripgrep
        zoxide
        imagemagick
        transmission_4-qt
        wl-clipboard
    ];

    programs.yazi = {
        enable = true;
        enableZshIntegration = true;

        plugins = {
            full-border = pkgs.yaziPlugins.full-border;
            smart-enter = pkgs.yaziPlugins.smart-enter;
            starship = pkgs.yaziPlugins.starship;
            recycle-bin = pkgs.yaziPlugins.recycle-bin;
        };

        settings = {
            manager = {
                show_hidden = true;
                sort_by = "natural";
                sort_dir_first = true;
                linemode = "size";
            };
            preview = {
                wrap = "yes";
                tab_size = 4;
            };

            opener = {
                edit = [{
                    run = ''nvim "$@"'';
                    block = true;
                }];

                open = [{
                    run = ''xdg-open "$@"'';
                }];

                image = [{
                    run = ''~/.local/bin/yazi-imv "$@"'';
                    orphan = true;
                }];
            };

            open = {
                prepend_rules = [{
                    mime = "image/*";
                    use = "image";
                }];
            };
        };
    };

    home.file.".local/bin/yazi-imv" = {
        executable = true;
        text = ''        
            #!/usr/bin/env bash

            dir="$(dirname "$1")"

            find "$dir" -maxdepth 1 \
            -type f \
            \( \
                -iname "*.png" -o \
                -iname "*.jpg" -o \
                -iname "*.jpeg" -o \
                -iname "*.webp" -o \
                -iname "*.gif" \
            \) \
            -print0 | xargs -0 imv
        '';
    };

	programs.home-manager.enable = true;
}
