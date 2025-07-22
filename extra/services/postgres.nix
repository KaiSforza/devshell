# This module automatically configures postgres when the user enters the
# devshell.
#
# To start the server, invoke `postgres` in one devshell. Then start a second
# devshell to run the clients.
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

  cfg = config.services.postgres;
  createDB = optionalString cfg.createUserDB ''
    echo "CREATE DATABASE ''${USER:-$(id -nu)};" | postgres --single -E postgres
  '';

  setup-postgres = pkgs.writeShellScriptBin "setup-postgres" ''
    set -xeuo pipefail
    export PATH=${cfg.package}/bin:${pkgs.coreutils}/bin

    # Abort if the data dir already exists
    [[ ! -d "$PGDATA" ]] || exit 0

    initdb ${concatStringsSep " " cfg.initdbArgs}

    ${pkgs.ripgrep}/bin/rg unix_socket $PGDATA/postgresql.conf

    env | ${pkgs.ripgrep}/bin/rg '^PG'

    cat >> "$PGDATA/postgresql.conf" <<EOF
    listen_addresses = '''
    unix_socket_directories = '$PGHOST'
    EOF

    ${createDB}
  '';

  start-postgres = pkgs.writeShellScriptBin "start-postgres" ''
    set -xeuo pipefail
    ${setup-postgres}/bin/setup-postgres
    exec ${cfg.package}/bin/postgres
  '';
in
{
  options.services.postgres = {
    package = mkOption {
      type = strOrPackage;
      description = "Which version of postgres to use";
      default = pkgs.postgresql;
      defaultText = "pkgs.postgresql";
    };

    setupPostgresOnStartup = mkEnableOption "call setup-postgres on startup";

    createUserDB = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Create a database named like current user on startup.
        This option only makes sense when `setupPostgresOnStartup` is true.
      '';
    };

    initdbArgs = mkOption {
      type = with types; listOf str;
      default = [ "--no-locale" ];
      example = [
        "--data-checksums"
        "--allow-group-access"
      ];
      description = ''
        Additional arguments passed to `initdb` during data dir
        initialisation.
      '';
    };

  };
  config = {
    packages = [
      cfg.package
    ];

    env = {
      PGDATA = {
        value = "\${PRJ_DATA_DIR:?}/postgres";
        eval = true;
      };
      PGHOST = {
        value = "\${PGDATA}";
        eval = true;
      };
    };

    devshell.startup.setup-postgres.text = lib.optionalString cfg.setupPostgresOnStartup ''
      ${setup-postgres}/bin/setup-postgres
    '';

    commands = {
      setup-postgres = {
        package = setup-postgres;
        help = "Setup the postgres data directory";
      };
      start-postgres = {
        package = start-postgres;
        help = "Start the postgres server";
        category = "databases";
      };
    };
  };
}
