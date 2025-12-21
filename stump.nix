{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, sqlite
, makeWrapper
, nodejs
, yarn
, fetchYarnDeps
, fixup-yarn-lock
, git
}:

let
  pname = "stump";
  version = "unstable";

  # Use local source for development
  src = ./.;

  # Fetch yarn dependencies using canonical nixpkgs helper
  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-BmDaEBmpKt4QPOCbuPsJ0q8Du3fs8eqqwPi6RJd3UMg=";
  };

  # Frontend build
  frontend = stdenv.mkDerivation {
    pname = "${pname}-frontend";
    inherit version src;

    nativeBuildInputs = [ nodejs yarn fixup-yarn-lock ];

    configurePhase = ''
      runHook preConfigure

      export HOME=$TMPDIR

      # Standard nixpkgs pattern for yarn dependencies
      fixup-yarn-lock yarn.lock
      yarn config --offline set yarn-offline-mirror ${offlineCache}

      # Install from offline cache
      yarn install --offline --frozen-lockfile --ignore-scripts --no-progress --non-interactive

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      cd apps/web
      NODE_ENV=production ${nodejs}/bin/node ../../node_modules/vite/bin/vite.js build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out/

      runHook postInstall
    '';
  };

in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoHash = "sha256-41XHyuejKftGGYcG9zS93cmtT6eXDwtHT3JCFt6YPLM=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    git
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  # Patch Cargo.toml to remove unwanted workspace members
  postPatch = ''
    sed -i '/core\/integration-tests/d' Cargo.toml
    sed -i '/apps\/desktop\/src-tauri/d' Cargo.toml
  '';

  # Tell openssl-sys to use system OpenSSL instead of building from source
  OPENSSL_NO_VENDOR = "1";

  buildAndTestSubdir = "apps/server";

  # Skip tests for now
  doCheck = false;

  postInstall = ''
    # Copy the frontend to the output
    mkdir -p $out/share/stump/client
    cp -r ${frontend}/* $out/share/stump/client/

    # Wrap the binary to set default client directory
    wrapProgram $out/bin/stump_server \
      --set STUMP_CLIENT_DIR $out/share/stump/client
  '';

  meta = with lib; {
    description = "A free and open source comics, manga and digital book server with OPDS support";
    homepage = "https://github.com/stumpapp/stump";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
