template = """
= Current Employees

#table(
  columns: (1fr, auto, auto),
  [*User*], [*Salary*], [*Age*],
  <%= employees %>
)
"""

defmodule Helper do 
  @names ["John", "Nathalie", "Joe", "Jane", "Jose", "Alex", "Tyler"]

  def build_employees(n) do 
    for _ <- 1..n do 
      [Enum.random(@names), Enum.random(1000..15_000), Enum.random(16..60)]
    end
  end
end

Benchee.run(
  %{
    "generate table" => 
      fn input -> 
        {:ok, _pdf_binary} = ExTypst.render_to_pdf(template, 
          employees: ExTypst.Format.table_content(input)
        )
      end,
  },
  inputs: %{
    "500 entries" => Helper.build_employees(500),
    "1000 entries" => Helper.build_employees(1_000),
    "5000 entries" => Helper.build_employees(5_000),
    "10000 entries" => Helper.build_employees(10_000),
  }
)
