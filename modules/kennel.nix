{ pkgs, lib, config, ... }:

let
  cfg = config.scottylabs.kennel;

  kennelConfigJSON = builtins.toJSON {
    services = lib.mapAttrs (_: svc: {
      custom_domain = svc.customDomain;
    }) cfg.services;

    static_sites = lib.mapAttrs (name: site: {
      package_attr = name;
      spa = site.spa;
      custom_domain = site.customDomain;
    }) cfg.sites;
  };
in
{
  options.scottylabs.kennel = {
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.customDomain = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Custom domain for this service";
        };
      });
      default = { };
      description = "Backend services deployed by kennel. Keys must match devenv process names.";
    };

    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          package = lib.mkOption {
            type = lib.types.package;
            description = "Nix derivation producing the static site files";
          };

          spa = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Serve index.html for all routes";
          };

          customDomain = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Custom domain for this static site";
          };
        };
      });
      default = { };
      description = "Static sites deployed by kennel";
    };

    config = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = "Generated kennel.json derivation for the builder to evaluate";
    };
  };

  config = lib.mkIf config.scottylabs.enable {
    scottylabs.kennel.config = pkgs.writeTextDir "kennel.json" kennelConfigJSON;
  };
}
