{
  # FIXME: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  pkgs,
  username,
  nix-index-database,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    # FIXME: select your core binaries that you always want on the bleeding-edge
    bat
    bottom
    coreutils
    curl
    du-dust
    fd
    findutils
    fx
    git
    git-crypt
    htop
    killall
    mosh
    procs
    sd
    tmux
    vim
    wget
  ]; #end of unstable-packages list

  stable-packages = with pkgs; [
    # FIXME: customize these stable packages to your liking for the languages that you use

    # FIXME: you can add plugins, change keymaps etc using (jeezyvim.nixvimExtend {})
    # https://github.com/LGUG2Z/JeezyVim#extending
    #jeezyvim
    (pkgs.jeezyvim.nixvimExtend {
      # you can put anything under the "Options" section of the NixVim docs here
      # https://nix-community.github.io/nixvim/

      # some examples...

      # all your regular vim options here
      options = {
        textwidth = 120;
      };

      config = {
      # add your own personal keymaps preferences
        keymaps = [
          {
            mode = "n";
            action = ":vsplit<CR>";
            key = "|";
          }

          {
            mode = "n";
            action = ":split<CR>";
            key = "-";
          }
        ]; #end of keymaps list

        plugins = {
          lsp.servers = {
            # full list of language servers you can enable on the left bar here:
            # https://nix-community.github.io/nixvim/plugins/lsp/servers/ansiblels/index.html

            graphql.enable = true;
          };

          # full list of plugins on the left bar here:
          # https://nix-community.github.io/nixvim/plugins/airline/index.html

          markdown-preview.enable = true;
        }; #end of jeezyvim exntend plugins
      }; # end of jeezyvim extend config
    })#end of jeezyvim package with extend features

    #my common packages
    neofetch
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # key tools
    gh # for bootstrapping
    just

    # core languages
    rustup

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    deadnix # nix
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
  ]; #end of stable packages list
in {
  imports = [
    nix-index-database.hmModules.nix-index
  ]; # end of imports block

  home.stateVersion = "24.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    # FIXME: set your preferred $SHELL
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish";
  }; #end of home block

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # FIXME: you can add anything else that doesn't fit into the above two lists in here
    [
      # pkgs.some-package
      # pkgs.unstable.some-other-package
    ]; # end of custom packages list

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;

    # FIXME: disable this if you don't want to use the starship prompt
    starship.enable = true;
    starship.settings = {
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = false;
      git_branch.style = "242";
      directory.style = "blue";
      directory.truncate_to_repo = false;
      directory.truncation_length = 8;
      python.disabled = true;
      ruby.disabled = true;
      hostname.ssh_only = false;
      hostname.style = "bold green";
    };

    # FIXME: disable whatever you don't want
    fzf.enable = true;
    fzf.enableFishIntegration = true;
    lsd.enable = true;
    lsd.enableAliases = true;
    zoxide.enable = true;
    zoxide.enableFishIntegration = true;
    zoxide.options = ["--cmd cd"];
    broot.enable = true;
    broot.enableFishIntegration = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = ""; # FIXME: set your git email
      userName = ""; #FIXME: set your git username
      extraConfig = {
        # FIXME: uncomment the next lines if you want to be able to clone private https repos
        # url = {
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
        # };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    # FIXME: This is my fish config - you can fiddle with it if you want
    fish = {
      enable = true;
      # FIXME: run 'scoop install win32yank' on Windows, then add this line with your Windows username to the bottom of interactiveShellInit
      # fish_add_path --append /mnt/c/Users/<Your Windows Username>/scoop/apps/win32yank/0.1.1
      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

        ${pkgs.lib.strings.fileContents (pkgs.fetchFromGitHub {
            owner = "rebelot";
            repo = "kanagawa.nvim";
            rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
            sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
          }
          + "/extras/kanagawa.fish")}

        set -U fish_greeting
      '';
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd $(mktemp -d)";
        show_path = "echo $PATH | tr ' ' '\n'";
        posix-source = ''
          for i in (cat $argv)
            set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
          end
        '';
      };
      shellAbbrs =
        {
          gc = "nix-collect-garbage --delete-old";
        }
        # navigation shortcuts
        // {
          ".." = "cd ..";
          "..." = "cd ../../";
          "...." = "cd ../../../";
          "....." = "cd ../../../../";
        }
        # git shortcuts
        // {
          gapa = "git add --patch";
          grpa = "git reset --patch";
          gst = "git status";
          gdh = "git diff HEAD";
          gp = "git push";
          gph = "git push -u origin HEAD";
          gco = "git checkout";
          gcob = "git checkout -b";
          gcm = "git checkout master";
          gcd = "git checkout develop";
          gsp = "git stash push -m";
          gsa = "git stash apply stash^{/";
          gsl = "git stash list";
        };
      shellAliases = {
        jvim = "nvim";
        lvim = "nvim";
        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
        
        # To use code as the command, uncomment the line below. Be sure to replace [my-user] with your username. 
        # If your code binary is located elsewhere, adjust the path as needed.
        # code = "/mnt/c/Users/[my-user]/AppData/Local/Programs/'Microsoft VS Code'/bin/code";
      };
      plugins = [
        {
          inherit (pkgs.fishPlugins.autopair) src;
          name = "autopair";
        }
        {
          inherit (pkgs.fishPlugins.done) src;
          name = "done";
        }
        {
          inherit (pkgs.fishPlugins.sponge) src;
          name = "sponge";
        }
      ]; #end of plugins list
    }; # end of git shortcuts
  }; #end of fish block
} # end of programs block
