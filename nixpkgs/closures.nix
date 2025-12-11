{ pkgs, nixpkgs, ... }:
let
  system = "loongarch64-linux";

  # NixOS/calamares-nixos-extensions/modules/nixos/main.py
  sharedConfig = {
    system.stateVersion = "25.11";
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };

    services.xserver.enable = true;

    services.printing.enable = true;
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      firefox
    ];
  };
  gnomeConfig = {
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
  };
  plasma6Config = {
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    environment.systemPackages = with pkgs; [
      kdePackages.kate
    ];
  };

  mkSystemPackage =
    config:
    (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        sharedConfig
        config
      ];
    }).config.system.build.toplevel;
in
{
  gnomeClosure = mkSystemPackage gnomeConfig;
  plasma6Closure = mkSystemPackage plasma6Config;
}
