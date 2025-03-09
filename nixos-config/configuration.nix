# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./wifi.nix
  ];

  nix = {
    package = pkgs.nixVersions.latest;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "kernel.sysrq" = 246;
  };

  networking.hostName = "hakurei";
  # Pick only one of the below networking options.
  networking.wireless = {
    enable = true; # Enables wireless support via wpa_supplicant.
    userControlled.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [anthy m17n mozc];
  };
  console = {
    #font = "Lat2-Terminus16";
    keyMap = "uk";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.displayManager.autoLogin.user = "score";

  programs.i3lock.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "gb";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable sound.
  # sound.enable = true;  # ALSA
  #hardware.pulseaudio.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.logind.lidSwitch = "ignore";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };

  programs.adb.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.score = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # Enable ‘sudo’ for the user.
      "adbusers"
    ];
    packages = with pkgs; [
      # Browsers
      firefox

      # Terminals
      rxvt-unicode
      kitty

      # Display
      arandr
      dunst
      feh
      picom

      # X11 startup scripts
      xorg.xkbcomp
      numlockx

      # IM
      discord
      element-desktop

      # Anime showings
      mpv
      ffmpeg
      pavucontrol

      # Yubikey
      yubioath-flutter

      # Command-line
      bat
      mosh
      delta
      pass

      prismlauncher
      gimp
    ];
  };

  fonts.packages = with pkgs; [
    # Terminal
    tewi-font
    terminus_font

    # Programming
    source-code-pro
    nerd-fonts.fira-code

    # Japanese
    mplus-outline-fonts.githubRelease
    hanazono

    # Toki pona
    linja-pi-pu-lukin
    nasin-nanpa
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [
      "DejaVu Serif"
      # Japanese
      "HanaMinA"
    ];
    sansSerif = [
      "DejaVu Sans"
      # Japanese
      "M PLUS 2"
    ];
    monospace = [
      "DejaVu Sans Mono"
      # Japanese
      "Mplus Code 60"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search nixpkgs wget
  environment.systemPackages = with pkgs; [
    # Common command-line wants
    wget
    tree
    file
    ripgrep

    # Sysadmin utilities
    htop
    nmon
    ncdu
    nethogs
    mtr
    # traceroute -> can use tracepath in simple cases
  ];

  environment.localBinInPath = true;
  environment.binsh = "${pkgs.dash}/bin/dash";

  programs.vim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.vim-full.customize {
      vimrcConfig = {
        # Compressed version of my usual vimrc settings + invoke into user vimrc
        customRC = ''
          scripte utf-8
          " {{{ Vim settings
          set nu ai sta et sw=0 ts=4 bg=dark wmnu mouse=a bs=indent,eol,start ic is hls enc=utf-8 ci
          set fdm=marker list listchars=tab:╾─,trail:·,nbsp:. completeopt=menu,preview,menuone
          set formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:
          set shortmess=filnxtToOI formatoptions+=jn nofsync lazyredraw
          set swapsync=
          syn on
          filetype plugin indent on
          highlight LineNr ctermbg=235
          " }}}
          " {{{ NetRW settings
          let g:netrw_banner = 0
          let g:netrw_liststyle = 3
          let g:netrw_browse_split = 4
          let g:netrw_altv = 1
          let g:netrw_winsize = 25
          " }}}
          " {{{ Filetype-specific settings
          au BufNewFile,BufRead *.sls,*.yml setl ft=yaml ts=2
          au BufNewFile,BufRead *.[ch] setl noet
          au BufNewFile,BufRead *.go setl noet
          au BufNewFile,BufRead ?akefile* setl noet nocindent
          " }}}
          " {{{ Keymap
          nnoremap <space> za
          nnoremap g] :pts <c-r>=expand("<cword>")<cr><cr>
          imap <C-C>\ <Plug>(copilot-suggest)
          imap <C-C>[ <Plug>(copilot-previous)
          imap <C-C>] <Plug>(copilot-next)
          " }}}
          if filereadable(expand("~/.vimrc"))
              source ~/.vimrc
          endif
        '';

        packages.mySystemVimPackageBundle = with pkgs.vimPlugins; {
          start = [
            ale
            copilot-vim
            vim-nix
            vim-smali
            ultisnips
          ];
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      . ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    promptInit = ""; # taken care of by grml
  };
  users.defaultUserShell = pkgs.zsh;

  programs.less.enable = true;
  programs.git.enable = true;

  programs.firejail.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "linja-pi-pu-lukin"
      "copilot.vim"
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # YubiKey stuff
  services.pcscd.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
