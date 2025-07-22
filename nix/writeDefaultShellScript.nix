{
  lib,
  writeTextFile,
  bash,
}:

/*
  Similar to writeShellScript, except that a default shebang can be provided

  Either the script already has a shebang, or one will be provided for it.
*/
{
  name,
  text,
  defaultShebang ? "#!${bash}/bin/bash\nset -euo pipefail\n",
  destination ? "/bin/${name}",
  checkPhase ? "",
  meta ? { },
  ...
}:
let
  script = if lib.hasPrefix "#!" text then text else "${defaultShebang}\n${text}";
in
writeTextFile
{
  inherit name checkPhase destination meta;
  text = script;
  executable = true;
}
