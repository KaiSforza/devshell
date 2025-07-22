{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  ansi = import ../nix/ansi.nix;

  # Because we want to be able to push pure JSON-like data into the
  # environment.
  strOrPackage = import ../nix/strOrPackage.nix { inherit lib pkgs; };

  writeDefaultShellScript = import ../nix/writeDefaultShellScript.nix {
    inherit (pkgs) lib writeTextFile bash;
  };

  pad = str: num: if num > 0 then pad "${str} " (num - 1) else str;

  # Fill in default options for a command.
  commandToPackage =
    name:
    cmd:
    if cmd.package == null && cmd.command == null then
      pkgs."${name}"
    else if cmd.package == null then
      writeDefaultShellScript {
        name = name;
        text = cmd.command;
        destination = cmd.destination or "/bin/${name}";
        checkPhase = cmd.checkPhase or "";
        meta.description = cmd.help;
      }
    else
      cmd.package;

  commandsToMenu =
    cmds:
    let
      cleanName =
        name: cmd:
        let
          pkg = commandToPackage name cmd;
        in
        cmd
        // {
          category = cmd.category or "general commands";
          help = if cmd.help != null then cmd.help else pkg.meta.description or "";
        };

      commands = lib.mapAttrs cleanName cmds;

      maxCommandLength = foldl'
        (m: v: if v > m then v else m)
        0 (
          map
          (name: stringLength name)
          (attrNames commands)
        );

      commandByCategories = lib.genAttrs (
        lib.unique (
        catAttrs "category" (attrValues commands)
        )
      )
      (
        category:
        lib.filterAttrs (_: x: x.category == category) commands
      );

      opCat =
        category:
        cmds:
        let
          opCmd =
            name: cmd:
            if cmd.help == null || cmd.help == ""
              then "  ${name}"
              else "  ${pad name (maxCommandLength - (stringLength name))} - ${cmd.help}";
        in
        "${ansi.bold}[${category}]${ansi.reset}\n" + concatStringsSep "\n" (lib.mapAttrsToList opCmd cmds);
    in
    concatStringsSep "\n" (lib.mapAttrsToList opCat commandByCategories) + "\n";

  # These are all the options available for the commands.
  commandOptions = {
    category = mkOption {
      type = types.str;
      default = "[general commands]";
      description = ''
        Set a free text category under which this command is grouped
        and shown in the help menu.
      '';
    };

    help = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Describes what the command does in one line of text.
      '';
    };

    command = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If defined, it will add a script with the name of the command, and the
        content of this value.

        By default it generates a bash script, unless a different shebang is
        provided.
      '';
      example = ''
        #!/usr/bin/env python
        print("Hello")
      '';
    };

    package = mkOption {
      type = types.nullOr strOrPackage;
      default = null;
      description = ''
        Used to bring in a specific package. This package will be added to the
        environment.
      '';
    };

    checkPhase = mkOption {
      type = types.nullOr types.str;
      default = "";
      description = ''
        Run this shell script as a check.
      '';
    };
  };

  defaultShebang = mkOption {
    type = types.oneOf [types.str or types.package];
    default = "#!${lib.getExe pkgs.bash}\nset -euo pipefail\n";
    description = "Set a different default shebang for all scripts.";
  };
in
{
  options = {
    inherit defaultShebang;
    commands = mkOption {
      type = types.attrsOf (types.submodule { options = commandOptions; });
      default = {};
      description = ''
        Add commands to the environment.
      '';
      example = literalExpression ''
        {
          hello = {
            help = "print hello";
            command = "echo hello";
          };
          nixpkgs-fmt = {
            category = "formatter";
          };
          foo = {
            package = pkgs.hello;
          };
        }
      '';
    };
  };
  config.defaultShebang = defaultShebang.default;

  config.commands = optionalAttrs (config.defaultShebang == defaultShebang.default) {
    menu = {
      help = "prints this menu";
      command = ''
        cat <<'DEVSHELL_MENU'
        ${commandsToMenu config.commands}
        DEVSHELL_MENU
      '';
    };
  };

  # Add the commands to the devshell packages. Either as wrapper scripts, or
  # the whole package.
  config.devshell.packages = lib.mapAttrsToList commandToPackage config.commands;
}
