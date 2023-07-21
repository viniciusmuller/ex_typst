# ExTypst

Elixir bindings and helpers for the [`typst`](https://github.com/typst/typst)
typesetting system.

Check [Typst's documentation](https://typst.app/docs) for a quick start.

# Usage

```elixir 
# Write typst markup
template = """
= Current Employees

This is a report showing the company's current employees.

#table(
  columns: (auto, 1fr, auto, auto),
  [*No*], [*Name*], [*Salary*], [*Age*],
  <%= employees %>
)
"""

# Create some data
defmodule Helper do 
  @names ["John", "Nathalie", "Joe", "Jane", "Tyler", ~s(", [*Strong*], $pi$, //)]
  @surnames ["Smith", "Johnson", "Williams", "Brown", "Jones", "Davis"]

  def build_employees(n) do 
    for n <- 1..n do 
      name = "#{Enum.random(@names)} #{Enum.random(@surnames)}"
      salary = "US$ #{Enum.random(1000..15_000) / 1}"
      [n, name, salary, Enum.random(16..60)]
    end
  end
end

# Convert it to a nice-looking PDF
{:ok, pdf_binary} = ExTypst.render_to_pdf(template, 
  employees: ExTypst.Format.table_content(Helper.build_employees(1_000))
)

# Write to disk
File.write!("employees.pdf", pdf_binary)

# Or maybe send via email
Bamboo.Email.put_attachment(email, %Bamboo.Attachment{data: pdf_binary, filename: "employees.pdf"})
```

You can see the generated PDF [here](./examples/employees.pdf).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_typst` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_typst, "~> 0.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_typst>.

