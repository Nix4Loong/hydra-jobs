{
  description = "Nix4Loong nix-loongarch-kernel source tarball";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs?ref=loong-master";
    nix-loongarch-kernel = {
      url = "github:nix4loong/nix-loongarch-kernel";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, nix-loongarch-kernel, ... }:
    let
      system = "loongarch64-linux";
      pkgs = import nixpkgs { inherit system; };

      common = import ../nixpkgs-tarball/common.nix;

      rev = nix-loongarch-kernel.rev or nix-loongarch-kernel.dirtyRev or "unknown";

      build = pkgs.runCommand "nix-loongarch-kernel-tarball" { } ''
        mkdir -p $out/nix-support $out/tarballs
        tar caf $out/tarballs/nixexprs.tar.xz -C ${nix-loongarch-kernel} .
        echo "${rev}" > $out/git-revision
        echo "file source-dist $out/tarballs/nixexprs.tar.xz" >> $out/nix-support/hydra-build-products
        echo "file txt $out/git-revision" >> $out/nix-support/hydra-build-products
      '';
    in
    {
      packages.${system}.default = build;

      hydraJobs = {
        tarball.${system} = build;
        runCommandHook.publish = common.mkRunCommandHook pkgs build "nix-loongarch-kernel";
      };
    };
}
