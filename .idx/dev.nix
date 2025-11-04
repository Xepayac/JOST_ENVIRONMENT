# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.python312
    pkgs.python312Packages.pip
    pkgs.python312Packages.pytest
    pkgs.python312Packages.pandas
    pkgs.python312Packages.pytest-cov
    pkgs.python312Packages.venvShellHook
    # --- Django Migration Packages ---
    pkgs.postgresql
    pkgs.python312Packages.django
    pkgs.python312Packages.djangorestframework
    pkgs.python312Packages.django-celery-results
    pkgs.python312Packages.psycopg2
    # --- End Django Migration ---
    pkgs.redis
  ];

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      # "vscodevim.vim"
    ];
  };
}
