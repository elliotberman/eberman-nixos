{ cargo
, clippy
, mkShell
, rust-analyzer-unwrapped
, rustfmt
, rustc
, rustPlatform
}:
rustPlatform.buildRustPackage {
  pname = "tmux-status";
  version = "0.1.0";
  src = ./src;

  cargoLock.lockFile = ./src/Cargo.lock;

  meta.mainProgram = "tmux-status";

  passthru.devShell = mkShell {
    packages = [
      cargo
      clippy
      rust-analyzer-unwrapped
      rustfmt
      rustc
    ];

    env.RUST_SRC_PATH = rustPlatform.rustLibSrc;
  };
}
