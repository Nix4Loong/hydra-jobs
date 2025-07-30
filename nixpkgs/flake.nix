{
  description = "Nix4Loong nixpkgs builds";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "loongarch64-linux"; };
      lib = pkgs.lib;

      # nixos/modules/services/desktop-managers/gnome.nix
      gnomePkgs = {
        inherit (pkgs)
          gnome-shell
          gnome-session
          mutter
          avahi
          geoclue2
          orca
          adwaita-icon-theme
          gnome-backgrounds
          gnome-bluetooth
          gnome-color-manager
          gnome-control-center
          gnome-tour
          gnome-user-docs
          glib
          gnome-menus
          xdg-user-dirs
          xdg-user-dirs-gtk
          baobab
          decibels
          epiphany
          gnome-text-editor
          gnome-calculator
          gnome-calendar
          gnome-characters
          gnome-clocks
          gnome-console
          gnome-contacts
          gnome-font-viewer
          gnome-logs
          gnome-maps
          gnome-music
          gnome-system-monitor
          gnome-weather
          loupe
          nautilus
          gnome-connections
          simple-scan
          snapshot
          totem
          yelp
          # gnome-software flatpak?
          evince
          file-roller
          geary
          gnome-disk-utility
          seahorse
          sushi
          bash
          zsh
          # games?
          # core-developer-tools?
          ;

        gtk3 = pkgs.gtk3.out;
      };

      # nixos/modules/services/desktop-managers/plasma6.nix
      plasma6Pkgs = {
        inherit (pkgs.kdePackages)
          qtwayland
          qtsvg
          frameworkintegration
          kauth
          kcoreaddons
          kded
          kfilemetadata
          kguiaddons
          kiconthemes
          kimageformats
          qtimageformats
          kio
          kio-admin
          kio-extras
          kio-fuse
          kpackage
          kservice
          kunifiedpush
          kwallet
          kwallet-pam
          kwalletmanager
          plasma-activities
          solid
          phonon-vlc
          kwin
          kscreen
          libkscreen
          kscreenlocker
          kactivitymanagerd
          kde-cli-tools
          kglobalacceld
          kwrited
          baloo
          milou
          kdegraphics-thumbnailers
          polkit-kde-agent-1
          plasma-desktop
          plasma-workspace
          drkonqi
          kde-inotify-survey
          libplasma
          plasma-integration
          kde-gtk-config
          breeze
          breeze-icons
          breeze-gtk
          ocean-sound-theme
          qqc2-breeze-style
          qqc2-desktop-style
          kdeplasma-addons
          kmenuedit
          kinfocenter
          plasma-systemmonitor
          ksystemstats
          libksysguard
          systemsettings
          kcmutils
          ;
        inherit (pkgs)
          hicolor-icon-theme
          xdg-user-dirs
          ;

        # Optional packages
        inherit (pkgs.kdePackages)
          aurorae
          plasma-browser-integration
          plasma-workspace-wallpapers
          konsole
          kwin-x11
          ark
          elisa
          gwenview
          okular
          kate
          khelpcenter
          dolphin
          baloo-widgets
          dolphin-plugins
          spectacle
          ffmpegthumbs
          krdp
          xwaylandvideobridge
          ;
        qttools = lib.getBin pkgs.kdePackages.qttools;

        # flatpak?
      };
    in
    {
      hydraJobs =
        {
          inherit (pkgs)
            bootspec
            btop
            fastfetch
            file
            fish
            hello
            htop
            jq
            lsof
            nano
            neofetch
            screen
            tmux
            tree
            wget
            ;
        }
        // gnomePkgs
        // plasma6Pkgs;
    };
}
