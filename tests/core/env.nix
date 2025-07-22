{
  pkgs,
  devshell,
  runTest,
}:
{
  # Test the environment variables
  env-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "devshell-env-1";
        env = {
          HTTP_PORT = {
            value = 8080;
          };
          PATH = {
            value = "bin";
            prefix = true;
          };
          XDG_CACHE_DIR = {
            value = "\${PRJ_ROOT}/$(echo .cache)";
            eval = true;
          };
          CARGO_HOME = {
            unset = true;
          };
        };
      };
    in
    runTest "devshell-env-1" { } ''
      export CARGO_HOME=woot
      unset XDG_DATA_DIRS

      # Load the devshell
      source ${shell}/env.bash

      assert "$XDG_DATA_DIRS" == "$DEVSHELL_DIR/share:/usr/local/share:/usr/share"

      assert "$HTTP_PORT" == 8080

      assert "''${CARGO_HOME-not set}" == "not set"

      # PATH is prefixed with an expanded bin folder
      [[ $PATH == $PWD/bin:* ]]

      # Eval
      assert "$XDG_CACHE_DIR" == "$PWD/.cache"
    '';
}
