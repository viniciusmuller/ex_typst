defmodule ExTypstTest do
  use ExUnit.Case
  doctest ExTypst

  test "render_to_string/2" do
    users = [
      ["John", 200, 10],
      ["Mary", 500, 100]
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

  test "escapes content" do
    content = """
    = Heading

    The name of the employee is <%= name %>. Content is properly escaped!
    """

    assert ExTypst.render_to_string(content, name: "\"*Strong*\"") ==
      """
      = Heading

      The name of the employee is \"\\\"*Strong*\\\"\". Content is properly escaped!
      """
  end
end
