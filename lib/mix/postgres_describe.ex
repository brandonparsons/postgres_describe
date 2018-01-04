defmodule Mix.Tasks.PostgresDescribe do
  @moduledoc """
  Puts output of Postgres describe in a set of files on disk.

  Usage:

  ```bash
  $ mix postgres_describe
  ```

  """

  use Mix.Task
  @shortdoc "Puts output of Postgres describe in a set of files on disk"

  @doc false
  def run(_), do: PostgresDescribe.go!()
end
