{
  description = "Nix4Loong NixOS image builds";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "loongarch64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };

      release = import "${nixpkgs}/nixos/release.nix" {
        supportedSystems = [ system ];
        configuration = ./config.nix;
      };

      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      nixpkgsRev = lock.nodes.nixpkgs.locked.rev;

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
