{ lib, config, ... }:

let
  cfg = config.scottylabs.cachix;
in
{
  options.scottylabs.cachix = {
    push = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Push builds to the `scottylabs` cachix cache. The auth token
        is read from OpenBao at `secret/shared/cachix` on shell entry.
      '';
    };
  };

  config = lib.mkIf (config.scottylabs.enable && cfg.push) {
    scottylabs.secrets.enable = lib.mkDefault true;

    enterShell = ''
      if token=$(bao kv get -field=CACHIX_AUTH_TOKEN secret/shared/cachix 2>/dev/null); then
        export CACHIX_AUTH_TOKEN="$token"
      else
        echo "warning: could not read CACHIX_AUTH_TOKEN from OpenBao; cachix push will fail. Run 'bao login -oidc' if not authenticated." >&2
      fi
    '';

    cachix.push = "scottylabs";
  };
}
