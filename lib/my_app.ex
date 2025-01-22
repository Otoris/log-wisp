defmodule MyApp do
  use GenServer
  @moduledoc """
  Main entry point for the application.
  """
  @doc """
  Starts the GenServer with the given filename!
  """
  @spec start_link(String.t()) :: {:ok, pid()} | {:error, term()}
  def start_link(filename) do
    case File.read(filename) do
      {:ok, _contents} ->
        GenServer.start_link(__MODULE__, filename, name: __MODULE__)
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Tries to read minecraft_fabric.log and returns the first line. Otherwise, it returns an error message.
  """
  @impl true
  @spec init(String.t()) :: {:ok, pid()} | {:error, term()}
  def init(filename) do
    # Read file contents minecraft_fabric.log
    stream_file(filename)
    {:ok, filename}
  end

  defp stream_file(filename) do
    Task.start(fn ->
      File.stream!(filename, [])
      |> Stream.each(fn line ->
        IO.puts(line)
        send(self(), {:line, line})
      end)
      |> Stream.run()
    end)
  end
end
