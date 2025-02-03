defmodule MyApp do
  use GenServer
  require Logger

  @moduledoc """
  Main entry point for the application.
  """

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(filename) do
    GenServer.start_link(__MODULE__, filename, name: __MODULE__)
  end

  @impl true
  def init(filename) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: ["../"])
    FileSystem.subscribe(watcher_pid)
    initial_content = File.read!(filename)

    {:ok,
     %{
       filename: filename,
       last_content: initial_content,
       last_line: nil
     }}
  end

  @impl true
  def handle_info({:file_event, _watcher_pid, {path, events}}, state) do
    if file_modified?(path, events, state) do
      new_content = File.read!(path)
      new_lines = extract_new_lines(state.last_content, new_content)
      last_line = extract_last_line(new_lines, state.last_line)
      notify_new_lines(new_lines)
      new_state = %{state | last_content: new_content, last_line: last_line}
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  def handle_info({:file_event, watcher_pid, :stop}, %{watcher_pid: watcher_pid} = state) do
    IO.puts("Stopping wisp watcher")
    {:noreply, state}
  end

  def file_modified?(path, events, state) do
    Path.basename(path) == state.filename and :modified in events
  end

  defp extract_new_lines(old_content, new_content) do
    old_lines = String.split(old_content, "\n", trim: true)
    new_lines = String.split(new_content, "\n", trim: true)
    new_lines -- old_lines
  end

  defp extract_last_line([], last_line), do: last_line
  defp extract_last_line(lines, _), do: List.last(lines)

  defp notify_new_lines(new_lines) do
    Enum.each(new_lines, fn line ->
      IO.puts("New line: #{line}")
    end)
  end

  @impl true
  def terminate(reason, _) do
    Logger.error("Terminating due to: #{inspect(reason)}")
  end
end
