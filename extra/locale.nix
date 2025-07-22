{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.extra.locale;
in
{
  options.extra.locale = {
    lang = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Set the language of the project";
      example = "en_GB.UTF-8";
    };

    package = mkOption {
      type = types.package;
      description = "Set the glibc locale package that will be used on Linux";
      default = pkgs.glibcLocales;
      defaultText = "pkgs.glibcLocales";
    };
  };
  config.env =
    lib.optionalAttrs pkgs.stdenv.isLinux {
      LOCALE_ARCHIVE = {
        value = "${cfg.package}/lib/locale/locale-archive";
      };
    }
    // lib.optionalAttrs (cfg.lang != null) {
      LANG = cfg.lang;
      LC_ALL = cfg.lang;
    };
}
