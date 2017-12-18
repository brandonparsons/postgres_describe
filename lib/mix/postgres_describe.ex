defmodule Mix.Tasks.PostgresDescribe do
  use Mix.Task

  @shortdoc "Puts output of Postgres describe in a set of files on disk"

  @moduledoc """
  Puts output of Postgres describe in a set of files on disk.

  Usage:

  ```bash
  $ mix PostgresDescribe
  ```

  """

  @doc false
  def run(_), do: PostgresDescribe.go!()
end
