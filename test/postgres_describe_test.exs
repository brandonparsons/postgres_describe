defmodule PostgresDescribeTest do
  use ExUnit.Case
  doctest PostgresDescribe

  # ------------------------------------------ #

  @host "localhost"
  @port 5432
  @database "test_database"
  @schema "myschema"
  @public_table "test_table_one"
  @schema_table "test_table_two"

  # ------------------------------------------ #

  setup_all do
    run_pg_command "postgres", ~s|CREATE DATABASE #{@database};|
    run_pg_command @database, ~s|
      CREATE TABLE #{@public_table} (
        id serial PRIMARY KEY, type varchar (50) NOT NULL,
        color varchar (25) NOT NULL,
        count int4 NOT NULL DEFAULT 0,
        fake bool NOT NULL,
        inserted_at timestamp NOT NULL,
        updated_at timestamp NOT NULL
      );
    |
    run_pg_command @database, ~s|CREATE SCHEMA #{@schema};|
    run_pg_command @database, ~s|
      CREATE TABLE #{@schema}.#{@schema_table} (
        id serial PRIMARY KEY, type varchar (50) NOT NULL,
        color varchar (25) NOT NULL,
        count int4 NOT NULL DEFAULT 0,
        fake bool NOT NULL,
        inserted_at timestamp NOT NULL,
        updated_at timestamp NOT NULL
      );
    |

    on_exit fn ->
      run_pg_command "postgres", ~s|DROP DATABASE #{@database};|
    end

    :ok # No context is returned here
  end

  # ------------------------------------------ #

  describe "write_files" do
    test "behaves as expected" do
      Temp.track!
      tmp_path = Temp.path!
      config = %{
        host: @host,
        port: @port,
        user: current_system_user(),
        password: nil,
        database: @database,
        write_dir: tmp_path,
        tables: %{
          "public" => [@public_table],
          @schema => [@schema_table]
        }
      }
      PostgresDescribe.write_files(config)

      expected_public_file_path = Path.join([tmp_path, "public", "#{@public_table}.txt"])
      expected_schema_file_path = Path.join([tmp_path, @schema, "#{@schema_table}.txt"])

      public_content = File.read!(expected_public_file_path)
      schema_content = File.read!(expected_schema_file_path)

      assert String.contains? public_content, ~s|Table "public.test_table_one"|
      assert String.contains? schema_content, ~s|Table "#{@schema}.#{@schema_table}"|

      assert String.contains? public_content, "inserted_at"
      assert String.contains? public_content, "timestamp without time zone"

      assert String.contains? schema_content, "inserted_at"
      assert String.contains? schema_content, "timestamp without time zone"
    end
  end

  # ------------------------------------------ #

  describe "describe_table" do
    test "a table in the public schema" do
      output = PostgresDescribe.describe_table(@host, @port, current_system_user(), nil, @database, "public", @public_table)

      assert String.contains? output, ~s|Table "public.test_table_one"|
      assert String.contains? output, "Column"
      assert String.contains? output, "Type"
      assert String.contains? output, "id"
      assert String.contains? output, "integer"
      assert String.contains? output, "not null"
      assert String.contains? output, "count"
      assert String.contains? output, "integer"
      assert String.contains? output, "inserted_at"
      assert String.contains? output, "timestamp without time zone"
    end

    test "a table in another schema" do
      output = PostgresDescribe.describe_table(@host, @port, current_system_user(), nil, @database, @schema, @schema_table)

      assert String.contains? output, ~s|Table "#{@schema}.#{@schema_table}"|
      assert String.contains? output, "Column"
      assert String.contains? output, "Type"
      assert String.contains? output, "id"
      assert String.contains? output, "integer"
      assert String.contains? output, "not null"
      assert String.contains? output, "count"
      assert String.contains? output, "integer"
      assert String.contains? output, "inserted_at"
      assert String.contains? output, "timestamp without time zone"
    end
  end

  # ------------------------------------------ #

  describe "write_output" do
    test "writes to the expected location" do
      Temp.track!
      tmp_path = Temp.path!
      PostgresDescribe.write_output(tmp_path, "myschema", "mytable", "hello there")
      expected_file_path = Path.join([tmp_path, "myschema", "mytable.txt"])
      assert File.exists?(expected_file_path)
      assert "hello there" == File.read!(expected_file_path)
    end
  end

  # ------------------------------------------ #

  describe "ensure_string" do
    test "a string" do
      assert "hello" == PostgresDescribe.ensure_string("hello")
    end

    test "an atom" do
      assert "hello" == PostgresDescribe.ensure_string(:hello)
    end

    test "an integer" do
      assert "2" == PostgresDescribe.ensure_string(2)
    end
  end

  # ------------------------------------------ #

  defp current_system_user, do: System.cmd("whoami", []) |> Kernel.elem(0) |> String.trim()

  defp run_pg_command(database, command) do
    {_shell_text, 0} = System.cmd "psql", ["-d", database, "-c", command]
  end
end
