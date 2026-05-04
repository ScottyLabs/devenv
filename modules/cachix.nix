{ pkgs, lib, config, ... }:

let
  cfg = config.scottylabs.cachix;
in
{
  options.scottylabs.cachix = {
    push = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Push builds to the `scottylabs` cachix cache. Each developer
        must run this once, from inside any ScottyLabs devenv shell:
        `cachix authtoken $(bao kv get -field=CACHIX_AUTH_TOKEN secret/shared/cachix)`.
        Requires a prior `bao login -method=oidc`.
      '';
    };
  };

  config = lib.mkIf (config.scottylabs.enable && cfg.push) {
    packages = [ pkgs.cachix ];
    cachix.push = "scottylabs";
  };
}
