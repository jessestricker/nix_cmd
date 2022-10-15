{
  description = "A binding to the Nix command line application.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane/v0.8.0";
    crane.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    crane,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    craneLib = crane.lib.${system};
  in {
    packages.${system}.default = craneLib.buildPackage {
      src = craneLib.cleanCargoSource ./.;
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [cargo rustc rustfmt clippy rust-analyzer];
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
    };

    formatter.${system} = pkgs.writeShellApplication {
      name = "quiet-alejandra";
      runtimeInputs = with pkgs; [alejandra];
      text = ''${pkgs.alejandra}/bin/alejandra --quiet "$@"'';
    };
  };
}
