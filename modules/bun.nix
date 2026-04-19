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
    treefmt.config.settings.formatter.oxfmt.options = [
      "--config"
      (toString (pkgs.writeText "oxfmtrc.json" (builtins.toJSON {
        tabWidth = 4;
        useTabs = false;
        overrides = [{
          files = [ "**/*.yaml" "**/*.yml" "**/*.html" ];
          options.tabWidth = 2;
        }];
      })))
    ];

    git-hooks.hooks.oxlint = {
      enable = true;
      description = "A fast linter for JavaScript and TypeScript";
      package = pkgs.oxlint;
      entry = "${lib.getExe pkgs.oxlint} --fix --fix-suggestions --fix-dangerously";
      files = "\\.(js|cjs|mjs|jsx|ts|mts|cts|tsx)$";
      language = "system";
    };
  };
}
