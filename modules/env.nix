{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  envOptions = {
    value = mkOption {
      type =
        with types;
        nullOr (oneOf [
          str
          int
          bool
          package
        ]);
      default = null;
      description = "Shell-escaped value to set";
    };

    eval = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Like value but not evaluated by Bash. This allows to inject other
        variable names or even commands using the `$()` notation. You must
        include all evaluated variables in curly braces, using `\''${...}`
        to escape in double quotes, or the extra double single quotes when
        using multi-line strings.
      '';
      example = "\\\${OTHER_VAR}";
    };

    prefix = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Prepend to PATH-like environment variables.

        For example name = "PATH"; prefix = "bin"; will expand the path of
        ./bin and prepend it to the PATH, separated by ':'.
      '';
      example = "bin";
    };

    unset = mkEnableOption "unsets the variable";

    #__toString = mkOption {
    #  type = types.functionTo types.str;
    #  internal = true;
    #  readOnly = true;
    #  default = envToBash;
    #  description = "Function used to translate this submodule to Bash code";
    #};
  };

  envToBash =
    name:
    args':
    let
      args = {eval = false; prefix = false; unset = false;} //
        (if (typeOf args') != "set" then
          (optionalAttrs (args' == null) {unset = true;})
          // {value = args';}
        else args');
      value = args.value or null;
      valType = if args.unset || value == null then "unset"
        else if args.prefix then "prefix"
        else if args.eval then "eval"
        else "value";
      outstrs = {
        value = "export ${name}=${escapeShellArg (toString value)}";
        eval = "export ${name}=${toString value}";
        prefix = ''export ${name}="$(${pkgs.coreutils}/bin/realpath --canonicalize-missing "${toString value}")"''${${name}+:''${${name}}}'';
        unset = ''unset ${name}'';
      };
    in
    (
      assert assertMsg (
        !(name == "PATH" && ! args.prefix)
      ) "[[environ]]: ${name} should not override the value. Use 'prefix' instead.";
      outstrs."${valType}"
    );
  compareEnvs = left: right: let
    name' = match "^export ([^ =]+).*$" left;
    name = if name' == [] || name' == null then "" else head name';
    valname' = match "^export ([^ =]+).*$" right;
    valname = if valname' == [] || valname' == null then "" else head valname';
    vals = match "^export [^=]+=(.*)$" right;
    # Flatten it 2 layers to get the actual matches.
    innerVals = filter (x: x != valname) (
      lib.flatten (
        filter isList (map
          (filter isList)
          (map
            (split "\\\$\\{([0-9A-Za-z_]+)") (
              if vals == null then [] else vals
            )
          )
        )
      )
    );
    cinnerVals = if innerVals != null then innerVals else [];
    a = {
      aname = name;
      bvalname = valname;
      cvals = cinnerVals;
      vals-before-name = builtins.elem
        name
        cinnerVals;
      };
  in
    a.vals-before-name
  ;

  sortEnvs = x: let
    sl = lib.toposort compareEnvs x;
  in
    (sl.result or []) ++ (sl.cycle or []);
in
{
  options.envToBash = mkOption {
    type = types.functionTo types.str;
    internal = true;
    readOnly = true;
    default = envToBash;
    description = "Function used to translate this submodule to Bash code";
  };

  options.env = let
    defopts = {
      XDG_DATA_DIRS = {
        value = ''''${DEVSHELL_DIR}/share:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}'';
        eval = true;
      };
      PRJ_ROOT = {
        value = "\${PRJ_ROOT:-PWD}";
        eval = true;
      };
      # A per-project data directory for runtime information.
      PRJ_DATA_DIR = {
        value = "\${PRJ_DATA_DIR:-\${PRJ_ROOT}/.data}";
        eval = true;
      };
    };
  in mkOption {
    type = with types; attrsOf (nullOr (oneOf [
      (submodule { options = envOptions; })
      str
      int
      bool
      package
    ]));
    apply = x: defopts // x;
    default = defopts;
    description = ''
      Add environment variables to the shell. eval's MUST be in curly braces.

      Ordering will be set based the detected 'dependencies'. Variables will be
      checked for any sub-variables (`''${...}`) and will be set after those sub-
      variables are set.

      note: There is a change in behavior here. Because this is an attrSet now
      you cannot define the same variable twice and use `prefix = true`. The
      prefix will still work for default variables, like `$PATH` or whatever, but
      variable values should be combined in nix, not in the shell.
    '';
    example = literalExpression ''
      {
        HTTP_PORT = { value = 8080; };
        HTTP_REMOTE_PORT = 8081;
        PATH = { prefix = true; value = "bin"; };
        XDG_CACHE_DIR = { eval = true; value = "\''${PRJ_ROOT}/.cache"; };
        CARGO_HOME = null;
        EMPTY_VALUE = false;
        ALSO_EMPTY_VALUE = "";
      }
    '';
  };

  config = {
    # Default env
    devshell.startup_env = lib.concatStringsSep "\n" (
        sortEnvs (attrValues (mapAttrs envToBash config.env))
    );
  };
}
