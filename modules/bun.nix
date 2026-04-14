{ pkgs, lib, config, ... }:

let
  cfg = config.scottylabs.bun;
in
{
  options.scottylabs.bun = {
    enable = lib.mkEnableOption "Bun/JavaScript development toolchain";
  };

  config = lib.mkIf (config.scottylabs.enable && cfg.enable) {
    packages = with pkgs; [ bun ];

    treefmt.config.programs.oxfmt.enable = true;

    git-hooks.hooks.oxlint = {
      enable = true;
      settings.fix = [ "safe" "suggestions" "dangerously" ];
    };
  };
}
