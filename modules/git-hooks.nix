{ lib, config, ... }:

let
  cfg = config.scottylabs.git-hooks;
in
{
  options.scottylabs.git-hooks = {
    conventionalCommits = lib.mkEnableOption "conventional commit linting";
  };

  config = lib.mkIf cfg.conventionalCommits {
    git-hooks.hooks.convco.enable = true;
  };
}
