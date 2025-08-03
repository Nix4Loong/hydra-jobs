{
  description = "Nix4Loong nixpkgs builds";

  inputs = {
    nixpkgs.url = "github:loongson-community/nixpkgs/loong-testing";
  };

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "loongarch64-linux"; };
    in
    {
      hydraJobs = {
        inherit (pkgs)
          nixfmt
          hmcl
          ;
      };
    };
}
