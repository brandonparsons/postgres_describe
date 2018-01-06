defmodule PostgresDescribe.Config do
  @moduledoc """
  This module handles fetching values from the config with some additional
  niceties. Sourced from
  `https://gist.github.com/bitwalker/a4f73b33aea43951fe19b242d06da7b9`

  MIT license as per author.
  """

  @doc """
  Fetches a value from the config, or from the environment if {:system, "VAR"}
  is provided.

  An optional default value can be provided if desired.

  ## Example

      iex> {test_var, expected_value} = System.get_env |> Enum.take(1) |> List.first
      ...> Application.put_env(:myapp, :test_var, {:system, test_var})
      ...> ^expected_value = #{__MODULE__}.get(:myapp, :test_var)
      ...> :ok
      :ok

      iex> Application.put_env(:myapp, :test_var2, 1)
      ...> 1 = #{__MODULE__}.get(:myapp, :test_var2)
      1

      iex> :default = #{__MODULE__}.get(:myapp, :missing_var, :default)
      :default
  """
  @spec get(atom, atom, term | nil) :: term
  def get(app, key, default \\ nil) when is_atom(app) and is_atom(key) do
    case Application.get_env(app, key) do
      {:system, env_var} ->
        case System.get_env(env_var) do
          nil -> default
          val -> val
        end

      {:system, env_var, preconfigured_default} ->
        case System.get_env(env_var) do
          nil -> preconfigured_default
          val -> val
        end

      nil ->
        default

      val ->
        val
    end
  end

  @doc """
  Same as get/3, but returns the result as an integer. If the value cannot be
  converted to an integer, the default is returned instead.
  """
  @spec get_integer(atom(), atom(), integer()) :: integer
  def get_integer(app, key, default \\ nil) do
    case get(app, key, nil) do
      nil ->
        default

      n when is_integer(n) ->
        n

      n ->
        case Integer.parse(n) do
          {i, _} -> i
          :error -> default
        end
    end
  end

  @doc """
  Fetches a value from the config, or from the environment if {:system, "VAR"}
  is provided.

  If the environment variable is not set and no preconfigured default is
  provided it will raise an `ArgumentError`.
  """
  @spec get!(atom, atom) :: term | no_return
  def get!(app, key) when is_atom(app) and is_atom(key) do
    case Application.fetch_env!(app, key) do
      {:system, env_var} ->
        case System.get_env(env_var) do
          nil -> raise ArgumentError, message: "Environment variable #{env_var} not set"
          value -> value
        end

      {:system, env_var, preconfigured_default} ->
        case System.get_env(env_var) do
          nil -> preconfigured_default
          value -> value
        end

      val ->
        val
    end
  end
end
