defmodule MyAppTest do
  use ExUnit.Case
  doctest MyApp

  test "reads file" do
    assert {:ok, pid} = MyApp.start_link("minecraft_fabric.log")
    assert is_pid(pid)
  end

  test "does not read file" do
    assert {:error, _reason} = MyApp.start_link("non_existent_file.log")
  end

  test "streams new lines" do
    tmp_file = "tmp_stream_test.log"
    File.write!(tmp_file, "new line\n")

    {:ok, pid} = MyApp.start_link(tmp_file)
    assert is_pid(pid)
    File.write!(tmp_file, "2nd line\n", [:append])

    :timer.sleep(50)
    assert_receive {:line, "2nd line\n"}
  end
end
