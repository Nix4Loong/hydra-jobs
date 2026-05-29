{
  description = "Nix4Loong 26.05 nixpkgs builds";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs?ref=loong-release-26.05";
  };

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "loongarch64-linux";
        config.allowUnfree = true;
      };
    in
    {
      hydraJobs = import ../pkgs.nix { inherit pkgs nixpkgs; };
    };
}
