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
    ./postgres.nix
    ./secrets.nix
  ];

  options.scottylabs = {
    enable = lib.mkEnableOption "ScottyLabs shared development configuration";

    project.name = lib.mkOption {
      type = lib.types.str;
      description = "Project name, used for database naming, log filtering, and secrets path";
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

    git-hooks.hooks.treefmt.enable = true;
  };
}
