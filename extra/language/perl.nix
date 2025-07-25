{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.language.perl;
  strOrPackage = import ../../nix/strOrPackage.nix { inherit lib pkgs; };

in
with lib;
{
  options.language.perl = {
    extraPackages = mkOption {
      type = types.listOf strOrPackage;
      default = [ ];
      example = literalExpression "[ perl538Packages.FileNext ]";
      description = "List of extra packages (coming from perl5XXPackages) to add";
    };
    libraryPaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression "[ ./lib ]";
      description = "List of paths to add to PERL5LIB";
    };
    package = mkOption {
      type = strOrPackage;
      default = pkgs.perl;
      example = literalExpression "pkgs.perl538";
      description = "Which Perl package to use";
    };
  };

  config = {
    env = (mkIf (cfg.extraPackages != [ ]) {
      "PERL5LIB" = {
        prefix = true;
        value = pkgs.perlPackages.makeFullPerlPath cfg.extraPackages;
      };
    })
    // (mkIf (cfg.libraryPaths != [ ]) {
      PERL5LIB = {
        value = concatStringsSep ":" cfg.libraryPaths;
        prefix = true;
      };
    });
    devshell.packages = [ cfg.package ] ++ cfg.extraPackages;
  };
}
