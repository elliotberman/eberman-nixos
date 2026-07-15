# Bump geoclue2 to 2.8.1 for the [ip] method= config key (selects the IP
# geolocation backend). Mirrors nixpkgs PR #519210. Drop once nixpkgs ships 2.8.1.
final: prev: {
  geoclue2 = prev.geoclue2.overrideAttrs (prevAttrs: {
    version = "2.8.1";
    src = final.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "elliotberman";
      repo = "geoclue";
      rev = "786d8d437ff2e6cd398d23a437622f2a06a66882";
      hash = "sha256-0UKMOtalFUbJswBZIWb4AxubjDxHdNYZDtk29VyXMdE=";
    };

    mesonFlags = prevAttrs.mesonFlags or [ ] ++ [
      "-Dsystemd-sysusers-dir=${placeholder "out"}/lib/sysusers.d"
    ];
  });
}
