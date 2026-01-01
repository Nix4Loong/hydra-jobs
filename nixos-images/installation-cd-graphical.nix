{ nixpkgsPath }:
{ lib, ... }:
{
  imports = [ "${nixpkgsPath}/nixos/modules/installer/cd-dvd/installation-cd-base.nix" ];

  isoImage.edition = "graphical";
  isoImage.showConfiguration = lib.mkDefault false;

  specialisation = lib.mkForce {
    gnome.configuration =
      { config, ... }:
      {
        imports = [ "${nixpkgsPath}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix" ];
        isoImage.showConfiguration = true;
        isoImage.configurationName = "GNOME (Linux ${config.boot.kernelPackages.kernel.version})";
      };

    plasma.configuration =
      { config, ... }:
      {
        imports = [ "${nixpkgsPath}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix" ];
        isoImage.showConfiguration = true;
        isoImage.configurationName = "Plasma (Linux ${config.boot.kernelPackages.kernel.version})";
      };
  };
}


