defmodule ExTypst.Format do
  @moduledoc """
  Contains helper functions for converting elixir datatypes into
  the format that Typst expects.
  """

  @type column_data :: ExTypst.Safe.t()

  @spec table_content(list(list(column_data))) :: {:safe, iodata()}
  @doc """
  Converts a series of columns mapped as a nested list to a format that can be
  plugged in an existing table.

  ## Examples

      iex> columns = [["John", 10, 20], ["Alice", 20, 30]]
      iex> ExTypst.Format.table_content(columns)
      {:safe, ~s/[#"John"], [#"10"], [#"20"],\\n  [#"Alice"], [#"20"], [#"30"]/}
  """
  def table_content(columns) when is_list(columns) do
    content =
      Enum.map_join(columns, ",\n  ", fn row ->
        Enum.map_join(row, ", ", fn data ->
          ["[", ExTypst.Safe.to_iodata(data), "]"]
        end)
      end)

    {:safe, content}
  end
end
