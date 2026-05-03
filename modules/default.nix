{ pkgs, lib, config, ... }:

let
  cfg = config.scottylabs;
in
{
  imports = [
    ./claude.nix
    ./kennel.nix
    ./rust.nix
    ./bun.nix
    ./keycloak.nix
    ./postgres.nix
    ./sqlite.nix
    ./secrets.nix
    ./valkey.nix
  ];

  options.scottylabs = {
    enable = lib.mkEnableOption "ScottyLabs shared development configuration";

    project.name = lib.mkOption {
      type = lib.types.str;
      description = "Project name, used for database naming, log filtering, and secrets path";
    };

    conventionalCommits.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enforce Conventional Commits via the commitizen git hook";
    };
  };

  config = lib.mkIf cfg.enable {
    cachix.pull = [ "scottylabs" ];

    treefmt = {
      enable = true;
      config.programs = {
        nixpkgs-fmt = {
          enable = true;
          excludes = [ "Cargo.nix" "bun.nix" ];
        };
        mdformat.enable = true;
      };
    };

    git-hooks.hooks = {
      treefmt.enable = true;
      commitizen.enable = cfg.conventionalCommits.enable;
    };
  };
}
