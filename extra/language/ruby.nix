{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.language.ruby;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };
in
with lib;
{
  imports = [ ./c.nix ];
  options.language.ruby = {
    nativeDeps = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "Use this when your gems depend on a dynamic library";
    };
    package = mkOption {
      type = strOrPackage;
      default = pkgs.ruby_3_2;
      defaultText = "pkgs.ruby_3_2";
      description = "Ruby version used by your project";
    };
  };

  config = {
    language.c = {
      compiler = pkgs.gcc; # Lots of gems don't compile properly with clang
      libraries = cfg.nativeDeps;
      includes = cfg.nativeDeps;
    };
    devshell.packages = with pkgs; [
      cfg.package
      # Used by mkmf, the standard gem build tool
      (lowPrio binutils)
      file
      findutils
      gnumake
    ];
    env = {
      CC = "cc";
      CPP = "cpp";
      CXX = "c++";
      GEM_HOME = {
        value = "\${PRJ_DATA_DIR}/ruby/bundle/$(ruby -e 'puts RUBY_VERSION')";
        eval = true;
      };
      PATH = {
        value = "\${GEM_HOME}/bin";
        prefix = true;
      };
    };
  };
}
