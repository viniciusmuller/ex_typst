defmodule ExTypst.FormatTest do
  use ExUnit.Case
  doctest ExTypst.Format

  describe "table_content/1" do
    test "render integers and strings as expected" do
      users = [
        ["John", 200, 10],
        ["Mary", 500, 100]
      ]

      expected = ~s/"John", "200", "10",\n  "Mary", "500", "100"/

      assert ExTypst.Format.table_content(users) == {:safe, expected}
    end
  end
end
