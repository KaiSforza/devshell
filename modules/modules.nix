{ pkgs, lib }:
let
  modules = [
    ./back-compat.nix
    ./commands.nix
    ./devshell.nix
    ./env.nix
    ./modules-docs.nix
    {
      # Configure modules-docs
      config.modules-docs.roots = [
        {
          url = "https://github.com/KaiSforza/devshell/attrs";
          path = toString ../.;
          branch = "attrs";
        }
      ];
    }
    ./services.nix
  ];

  pkgsModule =
    _:
    {
      config = {
        _module.args.baseModules = modules;
        _module.args.pkgsPath = lib.mkDefault pkgs.path;
        _module.args.pkgs = lib.mkDefault pkgs;
      };
    };
in
[ pkgsModule ] ++ modules
