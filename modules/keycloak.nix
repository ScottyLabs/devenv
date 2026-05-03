{ pkgs, lib, config, ... }:

let
  cfg = config.scottylabs.keycloak;

  realmFile = ".devenv/scottylabs-keycloak-realm.json";

  secretspecPath = /${config.devenv.root}/secretspec.toml;
  secretspec =
    if builtins.pathExists secretspecPath
    then builtins.fromTOML (builtins.readFile secretspecPath)
    else { };

  devProfile = secretspec.profiles.dev or { };

  clientId = devProfile.OIDC_CLIENT_ID.default or
    (throw "scottylabs.keycloak: secretspec.toml needs [profiles.dev].OIDC_CLIENT_ID.default");

  clientSecret = devProfile.OIDC_CLIENT_SECRET.default or
    (throw "scottylabs.keycloak: secretspec.toml needs [profiles.dev].OIDC_CLIENT_SECRET.default");

  realmSource = pkgs.writeText "scottylabs-keycloak-realm.json" (builtins.toJSON {
    realm = "scottylabs";
    enabled = true;
    sslRequired = "none";
    clients = [{
      clientId = clientId;
      secret = clientSecret;
      enabled = true;
      publicClient = false;
      standardFlowEnabled = true;
      directAccessGrantsEnabled = true;
      redirectUris = cfg.devClient.redirectUris;
      webOrigins = [ "+" ];
      protocolMappers = [{
        name = "groups";
        protocol = "openid-connect";
        protocolMapper = "oidc-group-membership-mapper";
        config = {
          "claim.name" = "groups";
          "full.path" = "true";
          "id.token.claim" = "true";
          "access.token.claim" = "true";
          "userinfo.token.claim" = "true";
        };
      }];
    }];
  });
in
{
  options.scottylabs.keycloak = {
    enable = lib.mkEnableOption "Keycloak with ScottyLabs defaults";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8088;
      description = "HTTP port Keycloak listens on locally";
    };

    devClient = {
      redirectUris = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "http://localhost:*/*" "http://127.0.0.1:*/*" ];
        description = "Permitted redirect URIs for the dev OIDC client";
      };
    };
  };

  config = lib.mkIf (config.scottylabs.enable && cfg.enable) {
    services.keycloak = {
      enable = true;
      settings = {
        http-host = "127.0.0.1";
        http-port = cfg.port;
      };
      realms.scottylabs = {
        path = realmFile;
        import = true;
      };
    };

    enterShell = ''
      mkdir -p "$DEVENV_ROOT/.devenv"
      install -m 0644 "${realmSource}" "$DEVENV_ROOT/${realmFile}"
      export KEYCLOAK_URL="http://127.0.0.1:${toString cfg.port}"
      export KEYCLOAK_ISSUER="$KEYCLOAK_URL/realms/scottylabs"
    '';
  };
}
