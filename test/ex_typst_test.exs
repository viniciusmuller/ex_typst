defmodule ExTypstTest do
  use ExUnit.Case

  test "add" do
    assert ExTypst.add(1, 2) == 3
  end

  test "render_to_string/2" do 
    users = [
      ["John", 200, 10],
      ["Mary", 500, 100],
    ]

    content = """
    = Financial Report

    #table(
      columns: (1fr, auto, auto),
      [*User*], [*Income*], [*Tax*],
      <%= users %>
    )
    """

    expected = """
    = Financial Report

    #table(
      columns: (1fr, auto, auto),
      [*User*], [*Income*], [*Tax*],
      "John", "200", "10",
      "Mary", "500", "100"
    )
    """

    formatted_users = ExTypst.Format.table_content(users)

    assert ExTypst.render_to_string(content, users: formatted_users) == expected
  end
end
