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
        Push successful builds to the `scottylabs` cachix cache. Each
        developer must run `cachix authtoken <token>` once before this
        works; ask a ScottyLabs lead for the token. Cachix dedupes by
        content hash, so re-pushing identical artifacts is a no-op.
      '';
    };
  };

  config = lib.mkIf (config.scottylabs.enable && cfg.push) {
    cachix.push = "scottylabs";
  };
}
