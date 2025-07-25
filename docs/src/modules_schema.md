## Options

### `commands`

Add commands to the environment. Can be used to add packages that will
be documented in the `menu` command.

**Type**:

```console
attribute set of (submodule)
```

**Default value**:

```nix
{ }
```

**Example value**:

```nix
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
  zsh = { };
}
```

**Declared in**:

- [modules/commands.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/commands.nix)

### `commands.<name>.package`

Used to bring in a specific package. This package will be added to the
environment. Useful if the package name doesn't map onto the main
executable name, such as with `openssh` and `ssh`.

**Type**:

```console
null or (package or string convertible to it)
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/commands.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/commands.nix)

### `commands.<name>.category`

Set a free text category under which this command is grouped
and shown in the help menu.

**Type**:

```console
string
```

**Default value**:

```nix
"[general commands]"
```

**Declared in**:

- [modules/commands.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/commands.nix)

### `commands.<name>.checkPhase`

Run this shell script as a check when building a custom command.

Only works if you use the `command` option as a string.

**Type**:

```console
null or string
```

**Default value**:

```nix
""
```

**Declared in**:

- [modules/commands.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/commands.nix)

### `commands.<name>.command`

If defined, it will add a script with the name of the command, and the
content of this value.

By default it generates a bash script, unless a different shebang is
provided.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
''
  #!/usr/bin/env python
  print("Hello")
''
```

**Declared in**:

- [modules/commands.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/commands.nix)

### `commands.<name>.help`

Describes what the command does in one line of text.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/commands.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/commands.nix)

### `devshell.packages`

The set of packages to appear in the project environment.

Those packages come from <https://nixos.org/NixOS/nixpkgs> and can be
searched by going to <https://search.nixos.org/packages>

**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.packagesFrom`

Add all the build dependencies from the listed packages to the
environment.

**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.interactive.<name>.deps`

A list of other steps that this one depends on.

**Type**:

```console
list of string
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.interactive.<name>.text`

Script to run.

**Type**:

```console
string
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.load_profiles`

Whether to enable load etc/profiles.d/*.sh in the shell.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.meta`

Metadata, such as 'meta.description'. Can be useful as metadata for downstream tooling.

**Type**:

```console
attribute set of anything
```

**Default value**:

```nix
{ }
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.motd`

Message Of The Day.

This is the welcome message that is being printed when the user opens
the shell.

You may use any valid ansi color from the 8-bit ansi color table. For example, to use a green color you would use something like {106}. You may also use {bold}, {italic}, {underline}. Use {reset} to turn off all attributes.

**Type**:

```console
string
```

**Default value**:

```nix
''
  {202}🔨 Welcome to devshell{reset}
  $(type -p menu &>/dev/null && menu)
''
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.name`

Name of the shell environment. It usually maps to the project name.

**Type**:

```console
string
```

**Default value**:

```nix
"devshell"
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.prj_root_fallback`

If IN_NIX_SHELL is nonempty, or DIRENV_IN_ENVRC is set to '1', then
PRJ_ROOT is set to the value of PWD.

This option specifies the path to use as the value of PRJ_ROOT in case
IN_NIX_SHELL is empty or unset and DIRENV_IN_ENVRC is any value other
than '1'.

Set this to null to force PRJ_ROOT to be defined at runtime (except if
IN_NIX_SHELL or DIRENV_IN_ENVRC are defined as described above).

Otherwise, you can set this to a string representing the desired
default path, or to a submodule of the same type valid in the 'env'
options list (except that the 'name' field is ignored).

**Type**:

```console
null or string
```

**Default value**:

```nix
"\${PRJ_ROOT:-\${PWD}}"
```

**Example value**:

```nix
{
  # Use the top-level directory of the working tree
  eval = "$(git rev-parse --show-toplevel)";
};
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.startup.<name>.deps`

A list of other steps that this one depends on.

**Type**:

```console
list of string
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `devshell.startup.<name>.text`

Script to run.

**Type**:

```console
string
```

**Declared in**:

- [modules/devshell.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/devshell.nix)

### `env`

Add environment variables to the shell. eval's MUST be in curly braces.

Ordering will be set based the detected 'dependencies'. Variables will be
checked for any sub-variables (`${...}`) and will be set after those sub-
variables are set.

note: There is a change in behavior here. Because this is an attrSet now
you cannot define the same variable twice and use `prefix = true`. The
prefix will still work for default variables, like `$PATH` or whatever, but
variable values should be combined in nix, not in the shell.

**Type**:

```console
attribute set of (null or (submodule) or string or signed integer or boolean or package)
```

**Default value**:

```nix
{
  PRJ_DATA_DIR = {
    eval = true;
    value = "\${PRJ_DATA_DIR:-\${PRJ_ROOT}/.data}";
  };
  PRJ_ROOT = {
    eval = true;
    value = "\${PRJ_ROOT:-PWD}";
  };
  XDG_DATA_DIRS = {
    eval = true;
    value = "\${DEVSHELL_DIR}/share:\${XDG_DATA_DIRS:-/usr/local/share:/usr/share}";
  };
}
```

**Example value**:

```nix
{
  HTTP_PORT = { value = 8080; };
  HTTP_REMOTE_PORT = 8081;
  PATH = { prefix = true; value = "bin"; };
  XDG_CACHE_DIR = { eval = true; value = "\${PRJ_ROOT}/.cache"; };
  CARGO_HOME = null;
  EMPTY_VALUE = false;
  ALSO_EMPTY_VALUE = "";
}
```

**Declared in**:

- [modules/env.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/env.nix)

### `extra.locale.package`

Set the glibc locale package that will be used on Linux
**Type**:

```console
package
```

**Default value**:

```nix
"pkgs.glibcLocales"
```

**Declared in**:

- [extra/locale.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/locale.nix)

### `extra.locale.lang`

Set the language of the project
**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Example value**:

```nix
"en_GB.UTF-8"
```

**Declared in**:

- [extra/locale.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/locale.nix)

### `git.hooks.enable`

Whether to enable install .git/hooks on shell entry.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.applypatch-msg.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.commit-msg.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.fsmonitor-watchman.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.post-update.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.pre-applypatch.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.pre-commit.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.pre-merge-commit.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.pre-push.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.pre-rebase.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `git.hooks.prepare-commit-msg.text`

Text of the script to install
**Type**:

```console
string
```

**Default value**:

```nix
""
```

**Declared in**:

- [extra/git/hooks.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/git/hooks.nix)

### `language.c.compiler`

Which C compiler to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
"pkgs.clang"
```

**Declared in**:

- [extra/language/c.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/c.nix)

### `language.c.includes`

C dependencies from nixpkgs
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [extra/language/c.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/c.nix)

### `language.c.libraries`

Use this when another language depends on a dynamic library
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [extra/language/c.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/c.nix)

### `language.go.package`

Which go package to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
<derivation go-1.24.4>
```

**Example value**:

```nix
pkgs.go
```

**Declared in**:

- [extra/language/go.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/go.nix)

### `language.go.GO111MODULE`

Enable Go modules
**Type**:

```console
one of "on", "off", "auto"
```

**Default value**:

```nix
"on"
```

**Declared in**:

- [extra/language/go.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/go.nix)

### `language.hare.package`

Which Hare package to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
<derivation hare-0.24.2>
```

**Example value**:

```nix
pkgs.hare
```

**Declared in**:

- [extra/language/hare.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/hare.nix)

### `language.hare.thirdPartyLibs`

List of extra packages (coming from hareThirdParty) to add
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
[ hareThirdParty.hare-compress ]
```

**Declared in**:

- [extra/language/hare.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/hare.nix)

### `language.hare.vendoredLibs`

List of paths to add to HAREPATH
**Type**:

```console
list of string
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
[ ./vendor/lib ]
```

**Declared in**:

- [extra/language/hare.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/hare.nix)

### `language.perl.package`

Which Perl package to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
<derivation perl-5.40.0>
```

**Example value**:

```nix
pkgs.perl538
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/perl.nix)

### `language.perl.extraPackages`

List of extra packages (coming from perl5XXPackages) to add
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
[ perl538Packages.FileNext ]
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/perl.nix)

### `language.perl.libraryPaths`

List of paths to add to PERL5LIB
**Type**:

```console
list of string
```

**Default value**:

```nix
[ ]
```

**Example value**:

```nix
[ ./lib ]
```

**Declared in**:

- [extra/language/perl.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/perl.nix)

### `language.ruby.package`

Ruby version used by your project
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
"pkgs.ruby_3_2"
```

**Declared in**:

- [extra/language/ruby.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/ruby.nix)

### `language.ruby.nativeDeps`

Use this when your gems depend on a dynamic library
**Type**:

```console
list of (package or string convertible to it)
```

**Default value**:

```nix
[ ]
```

**Declared in**:

- [extra/language/ruby.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/ruby.nix)

### `language.rust.enableDefaultToolchain`

Enable the default rust toolchain coming from nixpkgs
**Type**:

```console
boolean
```

**Default value**:

```nix
"true"
```

**Declared in**:

- [extra/language/rust.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/rust.nix)

### `language.rust.packageSet`

Which rust package set to use
**Type**:

```console
attribute set
```

**Default value**:

```nix
"pkgs.rustPlatform"
```

**Declared in**:

- [extra/language/rust.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/rust.nix)

### `language.rust.tools`

Which rust tools to pull from the platform package set
**Type**:

```console
list of string
```

**Default value**:

```nix
[
  "rustc"
  "cargo"
  "clippy"
  "rustfmt"
]
```

**Declared in**:

- [extra/language/rust.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/language/rust.nix)

### `serviceGroups`

Add services to the environment. Services can be used to group long-running processes.

**Type**:

```console
attribute set of (submodule)
```

**Default value**:

```nix
{ }
```

**Declared in**:

- [modules/services.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/services.nix)

### `serviceGroups.<name>.description`

Short description of the service group, shown in generated commands

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/services.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/services.nix)

### `serviceGroups.<name>.name`

Name of the service group. Defaults to attribute name in groups.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/services.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/services.nix)

### `serviceGroups.<name>.services`

Attrset of services that should be run in this group.

**Type**:

```console
attribute set of (submodule)
```

**Default value**:

```nix
{ }
```

**Declared in**:

- [modules/services.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/services.nix)

### `serviceGroups.<name>.services.<name>.command`

Command to execute.

**Type**:

```console
string
```

**Declared in**:

- [modules/services.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/services.nix)

### `serviceGroups.<name>.services.<name>.name`

Name of this service. Defaults to attribute name in group services.

**Type**:

```console
null or string
```

**Default value**:

```nix
null
```

**Declared in**:

- [modules/services.nix](https://github.com/KaiSforza/devshell/tree/attrs/modules/services.nix)

### `services.postgres.package`

Which version of postgres to use
**Type**:

```console
package or string convertible to it
```

**Default value**:

```nix
"pkgs.postgresql"
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/services/postgres.nix)

### `services.postgres.createUserDB`

Create a database named like current user on startup.
This option only makes sense when `setupPostgresOnStartup` is true.

**Type**:

```console
boolean
```

**Default value**:

```nix
true
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/services/postgres.nix)

### `services.postgres.initdbArgs`

Additional arguments passed to `initdb` during data dir
initialisation.

**Type**:

```console
list of string
```

**Default value**:

```nix
[
  "--no-locale"
]
```

**Example value**:

```nix
[
  "--data-checksums"
  "--allow-group-access"
]
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/services/postgres.nix)

### `services.postgres.setupPostgresOnStartup`

Whether to enable call setup-postgres on startup.
**Type**:

```console
boolean
```

**Default value**:

```nix
false
```

**Example value**:

```nix
true
```

**Declared in**:

- [extra/services/postgres.nix](https://github.com/KaiSforza/devshell/tree/attrs/extra/services/postgres.nix)

## Extra options

### `_module.args`

Additional arguments passed to each module in addition to ones
like `lib`, `config`,
and `pkgs`, `modulesPath`.

This option is also available to all submodules. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules. The sole exception to
this is the argument `name` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:
- {var}`lib`: The nixpkgs library.
- {var}`config`: The results of all options after merging the values from all modules together.
- {var}`options`: The options declared in all modules.
- {var}`specialArgs`: The `specialArgs` argument passed to `evalModules`.
- All attributes of {var}`specialArgs`

  Whereas option values can generally depend on other option values
  thanks to laziness, this does not apply to `imports`, which
  must be computed statically before anything else.

  For this reason, callers of the module system can provide `specialArgs`
  which are available during import resolution.

  For NixOS, `specialArgs` includes
  {var}`modulesPath`, which allows you to import
  extra modules from the nixpkgs package tree without having to
  somehow make the module aware of the location of the
  `nixpkgs` or NixOS directories.
  ```
  { modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/minimal.nix")
    ];
  }
  ```

For NixOS, the default value for this option includes at least this argument:
- {var}`pkgs`: The nixpkgs package set according to
  the {option}`nixpkgs.pkgs` option.

**Type**:

```console
lazy attribute set of raw value
```

**Declared in**:

- [lib/modules.nix]()
