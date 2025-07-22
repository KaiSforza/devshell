{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.language.c;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

  hasLibraries = lib.length cfg.libraries > 0;
  hasIncludes = lib.length cfg.includes > 0;
in
with lib;
{
  options.language.c = {
    libraries = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "Use this when another language dependens on a dynamic library";
    };

    includes = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      description = "C dependencies from nixpkgs";
    };

    compiler = mkOption {
      type = strOrPackage;
      default = pkgs.clang;
      defaultText = "pkgs.clang";
      description = "Which C compiler to use";
    };
  };

  config = {
    devshell.packages =
      [ cfg.compiler ]
      ++ (lib.optionals hasLibraries (map lib.getLib cfg.libraries))
      ++
        # Assume we want pkg-config, because it's good
        (lib.optionals hasIncludes ([ pkgs.pkg-config ] ++ (map lib.getDev cfg.includes)));

    env = (lib.optionalAttrs hasLibraries {
      LD_LIBRARY_PATH = {
        value = "\${DEVSHELL_DIR}/lib";
        prefix = true;
      };
      LDFLAGS = {
        value = "-L\${DEVSHELL_DIR}/lib";
        eval = true;
      };
    })
    // (lib.optionalAttrs hasIncludes {
      C_INCLUDE_PATH = {
        value = "\${DEVSHELL_DIR}/include";
        prefix = true;
      };
      PKG_CONFIG_PATH = {
        value = "\${DEVSHELL_DIR}/lib/pkgconfig";
        prefix = true;
      };
    });
  };
}
