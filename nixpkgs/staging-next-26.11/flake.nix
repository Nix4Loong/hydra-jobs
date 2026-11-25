{
  description = "Nix4Loong staging-next-26.11 nixpkgs builds";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs?ref=loong-staging-next-26.11";
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
