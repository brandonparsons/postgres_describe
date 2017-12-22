# Postgres Describe

This library provides a `Mix` task that documents PostgreSQL database tables
in files within the directory tree.

## Installation

Add `postgres_describe` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:postgres_describe, "~> 0.1"}
  ]
end
```

And `mix deps.get`.

## Basic Usage

The following configuration values are required **at a minimum**:
- `database`: Your PG database name
- `write_dir`: Where we should write your description files
- `tables` (map): Keys are schemas in your database (at a minimum you probably want `public`), and values are lists of table names within that schema

Additional configuration values you can set:
- `host`: Your PG host (defaults to `localhost`)
- `port`: PG port (defaults to `5432`)
- `user`: Your PG user (defaults to your current username, i.e. `whoami`)
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

A complete example configuration is shown below:

```elixir
config :postgres_describe,
  host: "localhost",
  port: 5432,
  user: "myuser",
  password: "mypassword",
  database: "mydatabase",
  write_dir: "/tmp",
  tables: %{
    public: [
      "table_1",
      "table_2"
    ],
    another_schema: [
      "table_3",
      "table_4"
    ]
  }
```

Once your system is configured, then run the generator from the root of your
application:

```bash
$ mix PostgresDescribe
```

Full docs can be found [online](https://hexdocs.pm/postgres_describe).
