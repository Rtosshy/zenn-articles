{
  description = "Zenn articles managed with Zenn CLI";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      devShells = forAllSystems (pkgs: {
        # zenn-cli needs Node >= 22.12.0; the CLI itself is pinned in package-lock.json.
        default = pkgs.mkShell {
          packages = [ pkgs.nodejs_24 ];
        };
      });
    };
}
