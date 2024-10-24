defmodule Altabarra.Utils do
  @moduledoc """
  Useful utilities.
  """

  @doc """
  Encode strings with special characters.
  """
  def encode(value) when is_binary(value) do
    URI.encode(value, &URI.char_unreserved?/1)
  end
end
