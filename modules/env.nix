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
      args = {eval = false; prefix = false; unset = false;} // args';
      value = args.value or null;
      valType = if args.unset || value == null then "unset"
        else if args.prefix then "prefix"
        else if args.eval then "eval"
        else "value";
    in
    (
      assert assertMsg (
        !(name == "PATH" && ! args.prefix)
      ) "[[environ]]: ${name} should not override the value. Use 'prefix' instead.";
      {
        value = "export ${name}=${escapeShellArg (toString value)}";
        eval = "export ${name}=${toString value}";
        prefix = ''export ${name}="$(${pkgs.coreutils}/bin/realpath --canonicalize-missing "${toString value}")"''${${name}+:''${${name}}}'';
        unset = ''unset ${name}'';
      }."${valType}"
    );
  compareEnvs = left: right: let
    name' = match "^export ([^ =]+).*$" (left);
    name = if name' == [] || name' == null then "" else head name';
    valname' = match "^export ([^ =]+).*$" (right);
    valname = if valname' == [] || valname' == null then "" else head valname';
    vals = match "^export [^=]+=(.*)$" (right);
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
  options.compareEnvs = mkOption {
    internal = true;
    readOnly = true;
    default = compareEnvs;
    description = "Testing";
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
    type = types.attrsOf (types.submodule { options = envOptions; });
    apply = x: defopts // x;
    default = defopts;
    description = ''
      Add environment variables to the shell. eval's MUST be in curly braces.
    '';
    example = literalExpression ''
      {
        HTTP_PORT = { value = 8080; };
        PATH = { prefix = true; value = "bin"; };
        XDG_CACHE_DIR = { eval = true; value = "\''${PRJ_ROOT}/.cache"; };
        CARGO_HOME = { value = null; };
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
