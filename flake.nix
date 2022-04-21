{
  description = "A flake for pythonification";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, utils}:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
        inherit system;
    };

  pythonPackages = pkgs.python39Packages;
  gmp = pkgs.gmp;


  venvDir = "./env";

  runPackages = with nixpkgs; [
      pythonPackages.python

      pythonPackages.venvShellHook
    ];

  devPackages = with nixpkgs; runPackages ++ [
      pythonPackages.pylint
      pythonPackages.flake8
      pythonPackages.black
      gmp
  ];

  # This is to expose the venv in PYTHONPATH so that pylint can see venv packages
  postShellHook = ''
    PYTHONPATH=\$PWD/\${venvDir}/\${pythonPackages.python.sitePackages}/:\$PYTHONPATH
    pip install -q -r requirements.txt
  '';

in {

#  runShell = pkgs.mkShell {
#    inherit venvDir;
#    name = "pythonify-run";
#    packages = runPackages;
#    postShellHook = postShellHook;
#  };
#  developmentShell = pkgs.mkShell {
#    inherit venvDir;
#    name = "pythonify-dev";
#    packages = devPackages;
#    postShellHook = postShellHook;
#  };
    devShell = with pkgs; mkShell {
      buildInputs = [];
      inherit venvDir;
      name = "pythonify-dev";
      packages = devPackages;
      postShellHook = postShellHook;
    };
  });
}
