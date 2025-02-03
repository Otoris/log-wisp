defmodule WispConfigTest do
  use ExUnit.Case, async: true
  doctest WispConfig

  alias WispConfig

  describe "load_config/1" do
    test "loads the configuration file" do
      config = WispConfig.load_config("default.config.json")
      assert config
    end

    test "raises an error if the file does not exist" do
      assert_raise RuntimeError, fn ->
        WispConfig.load_config("nonexistent.json")
      end
    end
  end

end
