defmodule MyAppTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  doctest MyApp

  alias MyApp

  describe "file_modified?/3" do
    test "returns true if filename matches and events include :modified" do
      state = %{filename: "testfile.log"}
      assert MyApp.file_modified?("/path/to/testfile.log", [:modified, :other], state)
    end

    test "returns false if filename does not match" do
      state = %{filename: "other.log"}
      refute MyApp.file_modified?("/path/to/testfile.log", [:modified], state)
    end

    test "returns false if events do not include :modified" do
      state = %{filename: "testfile.log"}
      refute MyApp.file_modified?("/path/to/testfile.log", [:created], state)
    end
  end

  describe "handle_info/2 with file events" do
    setup do
      tmp_dir = System.tmp_dir!()
      test_file = Path.join(tmp_dir, "testfile_#{:erlang.unique_integer([:positive])}.log")

      initial_content = "line1\nline2"
      File.write!(test_file, initial_content)

      # Return test_file and initial_content as part of the context.
      on_exit(fn -> File.rm(test_file) end)
      {:ok, test_file: test_file, initial_content: initial_content}
    end

    test "detects new line added to file", %{
      test_file: test_file,
      initial_content: initial_content
    } do
      state = %{
        filename: Path.basename(test_file),
        last_content: initial_content,
        last_line: nil
      }

      new_content = initial_content <> "\nline3"
      File.write!(test_file, new_content)

      output =
        capture_io(fn ->
          MyApp.handle_info({:file_event, self(), {test_file, [:modified]}}, state)
        end)

      assert output =~ "New line: line3"
    end

    test "ignores event if file does not match state.filename", %{
      test_file: test_file,
      initial_content: initial_content
    } do
      state = %{
        filename: "some_other_file.log",
        last_content: initial_content,
        last_line: nil
      }

      output =
        capture_io(fn ->
          MyApp.handle_info({:file_event, self(), {test_file, [:modified]}}, state)
        end)

      refute output =~ "New line"
    end

    test "ignores event when events do not include :modified", %{
      test_file: test_file,
      initial_content: initial_content
    } do
      state = %{
        filename: Path.basename(test_file),
        last_content: initial_content,
        last_line: nil
      }

      # Update file but send a different event type (e.g. :created)
      new_content = initial_content <> "\nline3"
      File.write!(test_file, new_content)

      output =
        capture_io(fn ->
          MyApp.handle_info({:file_event, self(), {test_file, [:created]}}, state)
        end)

      refute output =~ "New line: line3"
    end
  end
end
