defmodule MyApp.Greeter do
  @moduledoc """
  A simple module to greet someone.
  """

  @doc """
  Returns a greeting message for the given `name`.
  """
  def greet(name) do
    "Hello, #{name}!"
  end
end
