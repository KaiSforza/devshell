{
  devshell,
  runTest,
  ...
}:
{
  # Basic devshell usage
  commands-1 =
    let
      shell = devshell.mkShell {
        devshell.name = "commands-1";
        commands = {
          bash-script = {
            category = "hello";
            help = "Prints hello-bash";
            command = ''
              echo "hello-bash"
            '';
          };
          python-script = {
            category = "hello";
            help = "Prints hello-python";
            command = ''
              #!/usr/bin/env python3
              print("hello-python")
            '';
          };
          git = { package = "git"; };
          zsh = { };
        };
      };
    in
    runTest "devshell-1" { } ''
      # Load the devshell
      source ${shell}/env.bash

      menu

      # Checks that all the commands are available
      type -p bash-script
      type -p python-script
      type -p git
      type -p zsh

      assert "$(bash-script)" == hello-bash
      assert "$(zsh -c 'echo $ZSH_NAME')" == zsh

      # Check that the shebang is correct. We can't execute it inside of the
      # sandbox because /usr/bin/env doesn't exist.
      #
      # Ideally it would be rewritten with patchShebang.
      assert "$(head -n1 "$(type -p python-script)")" == "#!/usr/bin/env python3"
    '';
}
