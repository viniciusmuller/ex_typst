# ExTypst

Elixir bindings and helpers to the `typst` typesetting system.

> Currently, it is necessary to have `typst` on your path.
> 
> Support for using typst directly is planned.

# Usage

```Elixir 
# Write typst markup
template = """
= Current Employees

#table(
  columns: (1fr, auto, auto),
  [*User*], [*Salary*], [*Age*],
  <%= employees %>
)
"""

# Add some data
employees = [
  ["John", 2000, 20],
  ["Mary", 3500, 26],
]

# Convert it to a nice-looking PDF
{:ok, pdf_binary} = ExTypst.render_to_pdf(template, 
  employees: ExTypst.Format.table_content(employees)
)

# Write to disk
File.write!("employees.pdf", pdf_binary)

# Or maybe send via email
Bamboo.Email.put_attachment(email, %Bamboo.Attachment{data: pdf_binary, filename: "employees.pdf"})
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_typst` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_typst, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_typst>.

