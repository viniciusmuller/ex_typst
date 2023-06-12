template = """
= Current Employees

This is a report showing the company's current employees.

#table(
  columns: (auto, 1fr, auto, auto),
  [*No*], [*Name*], [*Salary*], [*Age*],
  <%= employees %>
)
"""

defmodule Helper do 
  @names ["John", "Nathalie", "Joe", "Jane", "Tyler"]
  @surnames ["Smith", "Johnson", "Williams", "Brown", "Jones", "Davis"]

  def build_employees(n) do 
    for n <- 1..n do 
      name = "#{Enum.random(@names)} #{Enum.random(@surnames)}"
      salary = "US$ #{Enum.random(1000..15_000) / 1}"
      [n, name, salary, Enum.random(16..60)]
    end
  end
end

{:ok, pdf_binary} = ExTypst.render_to_pdf(template, 
  employees: ExTypst.Format.table_content(Helper.build_employees(1_000))
)

File.write!("employees.pdf", pdf_binary)
IO.puts("Successfully written employees.pdf file")
