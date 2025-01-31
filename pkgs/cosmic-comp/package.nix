{ lib
, fetchFromGitHub
, rustPlatform
, libcosmicAppHook
, libinput
, mesa
, pixman
, pkg-config
, seatd
, stdenv
, udev
, xwayland
, useXWayland ? true
, systemd
, useSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd
, nix-update-script
}:

rustPlatform.buildRustPackage {
  pname = "cosmic-comp";
  version = "1.0.0-alpha.1-unstable-2024-08-10";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-comp";
    rev = "0916d3599a91fe40503209e0431fcc888fa6b867";
    hash = "sha256-9rWeViJe/ETVf1mW66iwygjbJec/m3wg910kOm0z3S4=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "atomicwrites-0.4.2" = "sha256-QZSuGPrJXh+svMeFWqAXoqZQxLq/WfIiamqvjJNVhxA=";
      "clipboard_macos-0.1.0" = "sha256-cG5vnkiyDlQnbEfV2sPbmBYKv1hd3pjJrymfZb8ziKk=";
      "cosmic-config-0.1.0" = "sha256-nZCefRCq40K0Mcsav+akZbX89kHnliqAkB7vKx5WIwY=";
      "cosmic-protocols-0.1.0" = "sha256-qgo8FMKo/uCbhUjfykRRN8KSavbyhZpu82M8npLcIPI=";
      "cosmic-settings-config-0.1.0" = "sha256-/Qav6r4VQ8ZDSs/tqHeutxYH3u4HiTBFWTfAYUSl2HQ=";
      "cosmic-text-0.12.1" = "sha256-x0XTxzbmtE2d4XCG/Nuq3DzBpz15BbnjRRlirfNJEiU=";
      "d3d12-0.19.0" = "sha256-usrxQXWLGJDjmIdw1LBXtBvX+CchZDvE8fHC0LjvhD4=";
      "glyphon-0.5.0" = "sha256-j1HrbEpUBqazWqNfJhpyjWuxYAxkvbXzRKeSouUoPWg=";
      "id_tree-1.8.0" = "sha256-uKdKHRfPGt3vagOjhnri3aYY5ar7O3rp2/ivTfM2jT0=";
      "smithay-0.3.0" = "sha256-4lmCbdW+fOnPWEDAbKk4LFcr9KK+akjUJqiwm0pK8Uw=";
      "smithay-clipboard-0.8.0" = "sha256-4InFXm0ahrqFrtNLeqIuE3yeOpxKZJZx+Bc0yQDtv34=";
      "smithay-egui-0.1.0" = "sha256-FcSoKCwYk3okwQURiQlDUcfk9m/Ne6pSblGAzHDaVHg=";
      "softbuffer-0.4.1" = "sha256-a0bUFz6O8CWRweNt/OxTvflnPYwO5nm6vsyc/WcXyNg=";
      "taffy-0.3.11" = "sha256-SCx9GEIJjWdoNVyq+RZAGn0N71qraKZxf9ZWhvyzLaI=";
    };
  };

  separateDebugInfo = true;

  nativeBuildInputs = [ libcosmicAppHook pkg-config ];
  buildInputs = [
    libinput
    mesa
    pixman
    seatd
    udev
  ] ++ lib.optional useSystemd systemd;

  # only default feature is systemd
  buildNoDefaultFeatures = !useSystemd;

  postInstall = ''
    mkdir -p $out/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1
    cp data/keybindings.ron $out/share/cosmic/com.system76.CosmicSettings.Shortcuts/v1/defaults
  '' + lib.optionalString useXWayland ''
    libcosmicAppWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ xwayland ]})
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex" "epoch-(.*)" ];
  };

  meta = with lib; {
    homepage = "https://github.com/pop-os/cosmic-comp";
    description = "Compositor for the COSMIC Desktop Environment";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ qyliss nyanbinary /*lilyinstarlight*/ ];
    platforms = platforms.linux;
  };
}
