defmodule PostgresDescribe do
  @moduledoc """
  This library provides a `Mix` task that documents PostgreSQL database tables
  in files within the directory tree.
  """

  use Private

  alias PostgresDescribe.Config

  # ------------------------------------------ #

  @default_host "localhost"
  @default_port 5432
  @default_password nil

  # ------------------------------------------ #

  @doc """
  Main entry point into `PostgresDescribe`'s library code. Takes no arguments,
  pulls configuration from the environment and/or defaults.

  The following configuration values are required **at a minimum**:
  - `database`: Your PG database name
  - `write_dir`: Where we should write your description files
  - `tables` (map): Keys are schemas in your database (at a minimum you probably want `public`), and values are lists of table names within that schema

  If any of these values are not provided, this function will raise an
  `ArgumentError`.

  Additional configuration values you can set:
  - `host`: Your PG host (defaults to `localhost`)
  - `port`: PG port (defaults to `5432`)
  - `user`: Your PG user (defaults to your current username, `whoami`)
  - `password`: Your PG password (defaults to `nil`)

  Configuration can be provided through your application config under the
  `postgres_describe` application:

  ```elixir
  config :postgres_describe,
    database: "mydatabase",
    write_dir: "/tmp/db_docs",
    tables: %{
      public: ["table1", "table2"]
    }
  ```

  Or through system environment variables.

  """
  def go! do
    :ok = write_files(get_config())
    {:ok, :complete}
  end

  defp get_config do
    %{
      host: Config.get(:postgres_describe, :host, @default_host),
      port: Config.get_integer(:postgres_describe, :port, @default_port),
      user: Config.get(:postgres_describe, :user, default_user()),
      password: Config.get(:postgres_describe, :password, @default_password),
      database: Config.get!(:postgres_describe, :database),
      write_dir: Config.get!(:postgres_describe, :write_dir),
      tables: Config.get!(:postgres_describe, :tables)
    }
  end

  defp default_user do
    {user, 0} = System.cmd("whoami", [])
    String.trim(user)
  end

  private do

    defp write_files(%{host: host, port: port, user: user, password: password,
                        database: database, write_dir: write_dir,
                        tables: tables}) do
      File.mkdir_p!(write_dir)
      Enum.each tables, fn({schema, table_list}) ->
        Enum.each table_list, fn(table) ->
          content = describe_table(host, port, user, password, database, schema, table)
          write_output(write_dir, schema, table, content)
        end
      end
    end

    defp describe_table(host, port, user, password, database, schema, table) do
      port_str = ensure_string(port)
      {shell_text, 0} = System.cmd "psql", ["-h", host, "-p", port_str, "-U", user, "-d", database, "-c", pg_command(schema, table)], env: env_opt(password)
      String.trim_trailing(shell_text)
    end

    defp write_output(write_dir, schema, table, output) do
      dir = Path.join([write_dir, ensure_string(schema)]) # The `tables` configuration could have been provided with atoms or string keys
      File.mkdir_p!(dir)
      file_path = Path.join([dir, table <> ".txt"])
      File.write!(file_path, output)
    end

    defp ensure_string(val) when is_binary(val), do: val
    defp ensure_string(val) when is_atom(val), do: Atom.to_string(val)
    defp ensure_string(val) when is_integer(val), do: Integer.to_string(val)

  end # private blcok

  # Note the double backslash - we want the `\d` postgres command
  defp pg_command(schema, table), do: ~s|\\d "#{schema}"."#{table}";|

  defp env_opt(nil), do: []
  defp env_opt(password), do: [{"PGPASSWORD", password}]
end
