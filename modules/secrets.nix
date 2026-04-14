{ pkgs, lib, config, ... }:

let
  cfg = config.scottylabs.secrets;
in
{
  options.scottylabs.secrets = {
    enable = lib.mkEnableOption "secretspec integration for local secret resolution";

    host = lib.mkOption {
      type = lib.types.str;
      default = "secrets2.scottylabs.org";
      description = "OpenBao server hostname";
    };

    profile = lib.mkOption {
      type = lib.types.str;
      default = "dev";
      description = "secretspec profile for local development";
    };
  };

  config = lib.mkIf (config.scottylabs.enable && cfg.enable) {
    packages = [ pkgs.secretspec pkgs.openbao ];

    env = {
      BAO_ADDR = "https://${cfg.host}";
      SECRETSPEC_PROVIDER = "vault://${cfg.host}/secret";
      SECRETSPEC_PROFILE = cfg.profile;
    };

    enterShell = ''
      if [ -f secretspec.toml ]; then
        if ! secretspec check 2>/dev/null; then
          echo "Secrets not loaded. Run 'bao login -method=oidc' then 'secretspec check' to set up secrets."
        fi
      fi
    '';
  };
}
