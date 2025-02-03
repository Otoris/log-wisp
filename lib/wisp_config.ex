defmodule WispConfig do
  @moduledoc """
  Functions for loading and parsing wisp configuration files.
  This module fallsback to the default.config.json file if no file is provided.
  default.config.json should be in the root of the project
  and informs the required keys for the configuration.
  """

  @spec load_config(String.t()) :: map()
  def load_config(filename) do
    case File.read(filename) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, config} -> validate_config(config)
          {:error, reason} -> raise "Failed to parse config: #{inspect(reason)}"
        end

      {:error, reason} ->
        raise "Failed to read config: #{inspect(reason)}"
    end
  end

  # Review this forum post https://elixirforum.com/t/how-to-decode-a-json-into-a-struct-safely/14331/25
  # look into struct casting - but also look into taking the fields from the default.config.json to use as the struct fields
  defp validate_config(config) do
    unless is_map(config) do
      raise "WispConfig must be a map"
    end

    # TODO - make required_keys load from the default.config.json file
    required_keys = ["REGEX_SERVER_PREFIX", "REGEX_MATCH_CHAT_MC", "REGEX_DEATH_MESSAGE"]
    missing_keys = Enum.filter(required_keys, fn key -> Map.get(config, key) == nil end)

    unless Enum.empty?(missing_keys) do
      raise "WispConfig is missing required keys: #{inspect(missing_keys)}"
    end

    config
  end
end
