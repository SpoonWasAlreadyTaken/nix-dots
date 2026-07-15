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

    home.file."imv/config".text = ''
        bind h prev
        bind l next
    '';

    /* home packages */

    home.packages = with pkgs; [
        tree-sitter
    ];

	programs.home-manager.enable = true;
}
