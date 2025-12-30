{
  description = "Stump - A free and open source comics, manga and digital book server";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flakelight.url = "github:nix-community/flakelight";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
    android-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { flakelight, android-nixpkgs, rust-overlay, ... } @ inputs:
    flakelight ./. {
      inherit inputs;

      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
      withOverlays = [ rust-overlay.overlays.default ];
      nixpkgs.config.allowUnfree = true;

      packages = { pkgs, system, lib, ... }: let
  rust = pkgs.rust-bin.stable."1.86.0".default;
  rustPlatform = pkgs.makeRustPlatform { cargo = rust; rustc = rust; };
  stumpPkg = pkgs.callPackage ./stump.nix { inherit rustPlatform; };
in {
  default = stumpPkg;
  stump = stumpPkg;
  android-sdk = android-nixpkgs.sdk.${system} (sdkPkgs: with sdkPkgs; [
    cmdline-tools-latest
    build-tools-34-0-0
    build-tools-35-0-0
    platform-tools  # fixed typo
    platforms-android-34
    platforms-android-35
    emulator
    ndk-26-1-10909125
        ] ++ lib.optionals (system == "aarch64-darwin") [
          # system-images-android-34-google-apis-arm64-v8a
          # system-images-android-34-google-apis-playstore-arm64-v8a
        ] ++ lib.optionals (system == "x86_64-darwin" || system == "x86_64-linux") [
          # system-images-android-34-google-apis-x86-64
          # system-images-android-34-google-apis-playstore-x86-64
        ]);
      };

      devShells = pkgs: let
        defaultPkgs = with pkgs; [
          git

          # node
          (nodePackages.yarn.override { withNode = false; })
          nodejs_20
          nodePackages.lerna

          rust
          rust-analyzer
          bacon

          # Build dependencies
          pkg-config
          dbus
          openssl
          sqlite
          curl
          wget
        ];
        libraryPkgs = with pkgs; [cairo
          gdk-pixbuf
          glib
          dbus
          openssl
          glib
          gtk3
          libsoup_3
          webkitgtk_6_0
        ];
        in {
          default.packages = defaultPkgs ++ libraryPkgs;
          default.shellHook = ''
            echo "Stump development environment"
            echo "Rust: $(rustc --version)"
            echo "Node: $(node --version)"
            echo "Yarn: $(yarn --version)"
          '';
          android.packages = flake: defaultPkgs ++ libraryPkgs ++ [ flake.outputs'.packages.android-sdk ];
       };
  };
}
