{
  description = "Garuda Linux iso-profiles flake ❄️";

  inputs = {
    devshell.url = "github:numtide/devshell";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # TODO: https://github.com/NixOS/nix/pull/9163
    src-buildiso = {
      type = "gitlab";
      owner = "garuda-linux";
      repo = "tools%2Fbuildiso-docker";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      forAllSystems =
        f:
        lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            let
              pkgs = import nixpkgs { inherit system; };
            in
            f (pkgs // { inherit system; })
          );
    in
    {
      checks = forAllSystems (pkgs: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${pkgs.system}.run {
          package = pkgs.prek;
          hooks = {
            commitizen.enable = true;
            nixfmt.enable = true;
            prettier.enable = true;
            yamllint.enable = true;
          };
          src = ./.;
        };
      });

      devShells = forAllSystems (
        {
          pkgs,
          system,
          ...
        }:
        let
          buildiso = ''
            if ! command -v docker &>/dev/null; then
              echo "This command requires Docker to be installed. Please install Docker and try again."
              exit 1
            fi
            if ! docker images | grep buildiso &>/dev/null; then
              docker build ${inputs.src-buildiso} -t buildiso
            fi
            docker run --rm -it --privileged --name buildiso \
                   -v "./buildiso/buildiso:/var/cache/garuda-tools/garuda-chroots/buildiso" \
                   -v "./buildiso/cron:/var/spool/anacron" \
                   -v "./buildiso/pkg:/var/cache/pacman/pkg/" \
                   -v "./buildiso/iso:/var/cache/garuda-tools/garuda-builds/iso/" \
                   -v "./buildiso/logs:/var/cache/garuda-tools/garuda-logs/" \
                   buildiso /bin/bash
          '';
          makeDevshell = import "${inputs.devshell.outPath}/modules" pkgs;
          mkShell =
            config:
            (makeDevshell {
              configuration = {
                inherit config;
                imports = [ ];
              };
            }).shell;
        in
        rec {
          default = garuda-shell;
          garuda-shell = mkShell {
            devshell.name = "garuda-shell";
            commands = [
              { package = "prek"; }
              {
                name = "buildiso";
                help = "Spawns a local buildiso shell to build to ./buildiso (needs Docker)";
                category = "infra-nix";
                command = buildiso;
              }
            ];
            devshell.startup = {
              preCommitHooks.text = self.checks.${system}.pre-commit-check.shellHook;
              garudaEnv.text = ''
                export LC_ALL="C.UTF-8"
                export NIX_PATH=nixpkgs=${nixpkgs}
              '';
            };
          };
        }
      );

      formatter = forAllSystems (
        { pkgs, ... }:
        pkgs.writeShellScriptBin "formatter" ''
          if [[ $# = 0 ]]; then set -- .; fi
          exec "${pkgs.nixfmt-rs}/bin/nixfmt" "$@"
        ''
      );
    };
}
