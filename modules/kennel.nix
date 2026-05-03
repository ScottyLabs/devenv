{ pkgs, lib, config, ... }:

let
  cfg = config.scottylabs.kennel;

  kennelConfigJSON = builtins.toJSON {
    services = lib.mapAttrs (_: svc: {
      custom_domain = svc.customDomain;
      oidc = if svc.oidc == null then null else {
        redirect_paths = svc.oidc.redirectPaths;
      };
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
        options = {
          customDomain = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Custom domain for this service";
          };

          oidc = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options.redirectPaths = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "Redirect URI paths (e.g. \"/oauth2/callback\"). Kennel ensures Keycloak prod and staging clients exist with the matching hosts derived from kennel's URL pattern, plus customDomain and PR previews.";
              };
            });
            default = null;
            description = "OIDC client config for this service";
          };
        };
      });
      default = { };
      description = "Backend services deployed by kennel. Keys must match devenv process names.";
    };

    sites = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
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
    scottylabs.kennel.config =
      let
        secretspecPath = /${config.devenv.root}/secretspec.toml;
        hasSecretspec = builtins.pathExists secretspecPath;
      in
      pkgs.runCommand "kennel-config" { } (''
        mkdir -p $out
        echo '${kennelConfigJSON}' > $out/kennel.json
      '' + lib.optionalString hasSecretspec ''
        cp ${secretspecPath} $out/secretspec.toml
      '');
  };
}
