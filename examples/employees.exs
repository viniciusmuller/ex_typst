template = """
= Current Employees

A *Serious Company* Report

#table(
  columns: (auto, 1fr, auto, auto),
  [*No*], [*User*], [*Salary*], [*Age*],
  <%= employees %>
)
"""

defmodule Helper do 
  @names ["John", "Nathalie", "Joe", "Jane", "Jose", "Alex", "Tyler"]

  def build_employees(n) do 
    for n <- 1..n do 
      [n, Enum.random(@names), Enum.random(1000..15_000), Enum.random(16..60)]
    end
  end
end

{:ok, pdf_binary} = ExTypst.render_to_pdf(template, 
  employees: ExTypst.Format.table_content(Helper.build_employees(5_000))
)

File.write!("employees.pdf", pdf_binary)
IO.puts("Succesfully written employees.pdf file")
