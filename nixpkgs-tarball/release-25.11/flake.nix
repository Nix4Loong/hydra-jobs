{
  description = "Nix4Loong 25.11 Nixpkgs Tarball";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs?ref=loong-release-25.11";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "loongarch64-linux";

      pkgs = import nixpkgs {
        inherit system;

        config = {
          permittedInsecurePackages = [ "nix-2.3.18" ];
        };
      };

      common = import ../common.nix;

      nixpkgsRev = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked.rev;
      build = common.mkBuild nixpkgs pkgs system nixpkgsRev;
    in
    {
      packages.loongarch64-linux.default = build;

      hydraJobs = {
        tarball.loongarch64-linux = build;
        runCommandHook.publish = common.mkRunCommandHook pkgs build "loong-release-25.11";
      };
    };
}
