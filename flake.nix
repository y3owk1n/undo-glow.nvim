{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/12a55407652e04dcf2309436eb06fef0d3713ef3?narHash=sha256-N4cp0asTsJCnRMFZ/k19V9akkxb7J/opG%2BK%2BjU57JGc%3D";
  };

  outputs =
    { nixpkgs, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      devShells = eachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              vimcats
            ];
          };
        }
      );
    };
}
