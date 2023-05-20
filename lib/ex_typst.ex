defmodule ExTypst do
  @moduledoc """
  Documentation for `ExTypst`.

  # Example

  ```Elixir 
  # Write markup
  template = """
    = Current Employees
    #table(
      columns: (1fr, auto, auto),
      [*User*], [*Salary*], [*Age*],
      <%= employees %>
    )
  \"""

  # Add some data
  employees = [
    ["John", 2000, 20],
    ["Mary", 3500, 26],
  ]

  # Convert it to a nice-looking PDF
  pdf_binary = ExTypst.render_to_pdf(template, 
    employees: ExTypst.Format.table_content(employees)
  )

  # Maybe mail it for someone?
  Bamboo.send_email!()

  # TODO: docs
  ```
  """

  def add(a, b) do
    ExTypst.NIF.add(a, b)
  end

  @spec render_to_string(String.t(), list({atom, any})) :: String.t()
  @doc """
  Formats the given markup template with the given bindings, mostly 
  useful for inspecting and debugging.
  """
  def render_to_string(typst_markup, bindings \\ []) do
    EEx.eval_string(typst_markup, bindings)
  end

  @spec render_to_pdf(String.t(), list({atom, any})) :: {:ok, binary()} | {:error, String.t()}
  @doc """
  # TODO
  """
  def render_to_pdf(typst_markup, bindings \\ []) do
    _markup = render_to_string(typst_markup, bindings)
    raise "TODO"
  end
end
