{
  description = "Nix4Loong Nixpkgs Tarball";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs";
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

      dist =
        (import "${nixpkgs}/pkgs/top-level/make-tarball.nix" {
          inherit pkgs nixpkgs;
          officialRelease = false;
          lib-tests = import "${nixpkgs}/lib/tests/release.nix" {
            inherit pkgs system;
          };
        }).overrideAttrs
          (_: {
            # Skip the generation of package.json
            checkPhase = ''
              mkdir -p $out/nix-support
              touch $out/nix-support/hydra-build-products;
            '';
          });

      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      nixpkgsRev = lock.nodes.nixpkgs.locked.rev;

      build = pkgs.runCommand "build" { } ''
        mkdir -p $out/nix-support $out/tarballs
        cp ${dist}/nix-support/hydra-release-name $out/nix-support/hydra-release-name
        cp ${dist}/tarballs/*.tar.xz $out/tarballs/nixexprs.tar.xz
        echo "${nixpkgsRev}" > $out/git-revision
        echo "file source-dist $out/tarballs/nixexprs.tar.xz" >> $out/nix-support/hydra-build-products
        echo "file txt $out/git-revision" >> $out/nix-support/hydra-build-products
      '';
    in
    {
      packages.loongarch64-linux.default = build;

      hydraJobs = {
        tarball.loongarch64-linux = build;

        runCommandHook.publish =
          let
            app = pkgs.writeShellApplication {
              name = "publish-hook";
              runtimeInputs = with pkgs; [
                curl
                jq
              ];
              text = ''
                set -euo pipefail

                PUBLISH_JSON=$(jq -n \
                  --arg tarball_path "${build}/tarballs/nixexprs.tar.xz" \
                  --arg revision_path "${build}/git-revision" \
                  '[
                    {
                      "from": $tarball_path,
                      "to": ("nix-channels/loong-master/"),
                      "overwrite": true
                    },
                    {
                      "from": $revision_path,
                      "to": ("nix-channels/loong-master/"),
                      "overwrite": true
                    }
                  ]')

                echo "Publishing JSON:"
                echo "$PUBLISH_JSON" | jq .

                if curl -fSs -X POST \
                  -H "Content-Type: application/json" \
                  -d "$PUBLISH_JSON" \
                  "http://127.0.0.1:8888/publish"; then
                  echo "Successfully published!"
                else
                  echo "Failed to publish"
                  exit 1
                fi
              '';
            };
          in
          pkgs.writeScript "publish.sh" ''
            #!${pkgs.runtimeShell}
            exec ${app}/bin/publish-hook "$@"
          '';
      };
    };
}
