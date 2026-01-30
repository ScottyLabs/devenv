{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.scottylabs;
  loadSecretsScript = pkgs.writeShellApplication {
    name = "load-secrets";
    runtimeInputs = [
      pkgs.openbao
      pkgs.jq
    ];
    text = builtins.readFile ./scripts/load-secrets.sh;
  };
in
{
  options.scottylabs = {
    team = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Team name for fetching secrets from secrets/<team>/dev/env";
    };

    bao.addr = lib.mkOption {
      type = lib.types.str;
      default = "https://secrets2.scottylabs.org";
      description = "OpenBao server address";
    };
  };

  config = lib.mkIf (cfg.team != null) {
    packages = [ loadSecretsScript ];

    enterShell = ''
      source <(load-secrets "${cfg.team}" "${cfg.bao.addr}")
    '';
  };
}
