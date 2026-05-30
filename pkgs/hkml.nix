{
  fetchFromGitHub,
  git,
  python3,
  writeShellApplication,
}:
writeShellApplication {
  name = "hkml";
  runtimeInputs = [
    git
    python3
  ];
  text =
    let
      src = fetchFromGitHub {
        owner = "sjp38";
        repo = "hackermail";
        tag = "v1.4.3";
        hash = "sha256-1r7sDugXODvvSZchVRTrxAzUM0126p8lzbGqKLurKIA=";
      };
    in
    ''
      python "${src}/src/hkml.py" "$@"
    '';
}
