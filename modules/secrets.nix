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
    packages = [ pkgs.openbao pkgs.secretspec ];

    env.BAO_ADDR = "https://${cfg.host}";

    secretspec = {
      provider = "vault://${cfg.host}/secret";
      profile = cfg.profile;
    };
  };
}
