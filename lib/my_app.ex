defmodule MyApp do
  use GenServer
  @moduledoc """
  Main entry point for the application.
  """

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(filename) do
    GenServer.start_link(__MODULE__, filename)
  end

  def init(filename) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: ["../"], file: filename)
    FileSystem.subscribe(watcher_pid)
    initial_content = File.read!(filename)
    {:ok, %{watcher_pid: watcher_pid, filename: filename, last_content: initial_content}}
  end

  def handle_info({:file_event, watcher_pid, {path, events}},
    %{watcher_pid: watcher_pid, filename: filename, last_content: last_content} = state) do

    if Path.basename(path) == filename and :modified in events do
      new_content = File.read!(path)
      new_lines = find_new_lines(last_content, new_content)

      Enum.each(new_lines, fn line ->
        IO.puts("New line: #{line}")
      end)

      {:noreply, %{state | last_content: new_content}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    # Your own logic when monitor stop
    IO.puts("Stopping wisp watcher")
    {:noreply, state}
  end

  defp find_new_lines(old_content, new_content) do
    old_lines = String.split(old_content, "\n")
    new_lines = String.split(new_content, "\n")
    new_lines -- old_lines
  end

end
