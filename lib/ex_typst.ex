defmodule ExTypst do
  @moduledoc """
  Documentation for `ExTypst`.
  """

  def add(a, b) do 
    ExTypst.NIF.add(a, b)
  end
end
