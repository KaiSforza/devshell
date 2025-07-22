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
    if cmd.package == null then
      writeDefaultShellScript {
        name = name;
        text = cmd.command;
        binPrefix = true;
      }
    else
      cmd.package;

  commandsToMenu =
    cmds:
    let
      cleanName =
        name: cmd:
        cmd
        // {
          category = cmd.category or "general commands";
          help = cmd.package.meta.description or cmd.help;
        };

      commands = lib.mapAttrs cleanName cmds;

      maxCommandLength = foldl'
        (m: v: if v > m then v else m)
        0 (
          map
          (name: stringLength name)
          (attrNames commands)
        );

      commandCategories = lib.unique (
        catAttrs "category" (attrValues commands)
      );

      commandByCategoriesSorted = lib.genAttrs commandCategories (
        category:
        lib.filterAttrs (_: x: x.category == category) commands
      );

      opCat =
        category:
        cmds:
        let
          opCmd =
            name: cmd:
            let
              len = maxCommandLength - (stringLength name);
            in
            if cmd.help == null || cmd.help == ""
              then "  ${name}"
              else "  ${pad name len} - ${cmd.help}";
        in
        "${ansi.bold}[${category}]${ansi.reset}\n" + concatStringsSep "\n" (attrValues (mapAttrs opCmd cmds));
    in
    concatStringsSep "\n" (attrValues (mapAttrs opCat commandByCategoriesSorted)) + "\n";

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
  };
in
{
  options.commands = mkOption {
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
          package = "nixpkgs-fmt";
          category = "formatter";
        };
      }
    '';
  };

  config.commands = {
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
  config.devshell.packages = attrValues (mapAttrs commandToPackage config.commands);
  # config.devshell.motd = "$(motd)";
}
