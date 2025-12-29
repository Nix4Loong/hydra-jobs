{
  description = "Nix4Loong trunk NixOS image builds";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs?ref=loong-master";
    nix-loongarch-kernel.url = "github:nix4loong/nix-loongarch-kernel";
  };

  outputs =
    { nixpkgs, nix-loongarch-kernel, ... }:
    let
      system = "loongarch64-linux";
      nixpkgsUrl = "https://download.nix4loong.cn/nix-channels/loong-master";

      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      nixpkgsRev = lock.nodes.nixpkgs.locked.rev;
      kernelRev = lock.nodes.nix-loongarch-kernel.locked.rev;

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            calamares-nixos-extensions = prev.calamares-nixos-extensions.overrideAttrs (oldAttrs: {
              patches = (oldAttrs.patches or [ ]) ++ [
                (prev.replaceVars ./calamares.patch { inherit kernelRev; })
              ];
            });
          })
        ];
      };

      release = import "${nixpkgs}/nixos/release.nix" {
        supportedSystems = [ system ];
        configuration = import ./config.nix {
          inherit nixpkgsUrl kernelRev;
          kernelPackages = nix-loongarch-kernel.legacyPackages.${system}.linuxPackages;
        };
      };

      build =
        input: name:
        pkgs.runCommand "build" { buildInputs = [ pkgs.coreutils ]; } ''
          mkdir -p $out/nix-support $out/iso
          cp ${input.${system}}/nix-support/system $out/nix-support

          iso="latest-nixos-${name}-loongarch64-linux.iso"
          cp ${input.${system}}/iso/nixos-*.iso $out/iso/$iso
          pushd $out/iso
            sha256sum $iso >> $iso.sha256
          popd
          echo "file iso $out/iso/$iso" >> $out/nix-support/hydra-build-products
          echo "file txt $out/iso/$iso.sha256" >> $out/nix-support/hydra-build-products

          echo "${nixpkgsRev}" > $out/git-revision
          echo "file txt $out/git-revision" >> $out/nix-support/hydra-build-products
        '';
      iso_minimal = build release.iso_minimal "minimal";
      iso_graphical = build release.iso_graphical "graphical";
    in
    {
      packages.${system} = {
        inherit iso_minimal iso_graphical;
      };

      hydraJobs = {
        iso_minimal.loongarch64-linux = iso_minimal;
        iso_graphical.loongarch64-linux = iso_graphical;

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
                  --arg revision_path "${iso_minimal}/git-revision" \
                  --arg minimal_path "${iso_minimal}/iso/" \
                  --arg graphical_path "${iso_graphical}/iso/" \
                  '[
                    {
                      "from": $minimal_path,
                      "to": ("nixos-images/loong-master/"),
                      "overwrite": true
                    },
                    {
                      "from": $graphical_path,
                      "to": ("nixos-images/loong-master/"),
                      "overwrite": true
                    },
                    {
                      "from": $revision_path,
                      "to": ("nixos-images/loong-master/"),
                      "overwrite": true
                    }
                  ]')

                echo "Publishing JSON:"
                echo "$PUBLISH_JSON" | jq .

                if curl -fSs -X POST \
                  -H "Content-Type: application/json" \
                  -d "$PUBLISH_JSON" \
                  "http://127.0.0.1:8888/publish"; then
                  echo "Successfully published"
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
