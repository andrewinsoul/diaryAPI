defmodule Mix.Tasks.LoadEnv do
  use Mix.Task

  def run(_) do
    System.cmd("sh", ["-c", "source .env"], stderr_to_stdout: true)
    IO.puts("env loaded")
  end
end
