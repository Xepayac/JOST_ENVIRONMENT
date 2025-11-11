# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "unstable"; # Using unstable to resolve dependency issues

  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.python312
    pkgs.python312Packages.pip
    pkgs.python312Packages.streamlit
    pkgs.python312Packages.pandas
    pkgs.python312Packages.pytest
  ];

  idx = {
    extensions = [
      # "vscodevim.vim"
    ];

    previews = {
      enable = true;
      previews = {
        web = {
          command = [
            ".venv/bin/streamlit" # Explicitly calling streamlit from our virtual environment
            "run"
            "app.py"
            "--server.port"
            "$PORT"
            "--server.headless"
            "true"
            "--server.enableCORS"
            "false"
            "--server.enableXsrfProtection"
            "false"
          ];
          manager = "web";
        };
      };
    };
  };
}
