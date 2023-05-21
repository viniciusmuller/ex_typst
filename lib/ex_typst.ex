defmodule ExTypst do
  @moduledoc """
  Documentation for `ExTypst`.

  # Example

  ```Elixir 
  # Write markup
  template = \"""
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

  @spec render_to_string(String.t(), list({atom, any})) :: String.t()
  @doc """
  Formats the given markup template with the given bindings, mostly 
  useful for inspecting and debugging.
  """
  def render_to_string(typst_markup, bindings \\ []) do
    EEx.eval_string(typst_markup, bindings)
  end

  @type pdf_opt :: {:extra_fonts, list(String.t)}

  @spec render_to_pdf(String.t(), list({atom, any}), list(pdf_opt)) :: {:ok, binary()} | {:error, String.t()}
  @doc """
  # TODO
  """
  def render_to_pdf(typst_markup, bindings \\ [], opts \\ []) do
    extra_fonts = Keyword.get(opts, :extra_fonts, [])
    markup = render_to_string(typst_markup, bindings)
    ExTypst.NIF.compile(markup, extra_fonts)
  end

  @spec render_to_pdf!(String.t(), list({atom, any})) :: binary()
  @doc """
  Same as `render_to_pdf/2`, but raises if the rendering fails.
  """
  def render_to_pdf!(typst_markup, bindings \\ []) do
    case render_to_pdf(typst_markup, bindings) do 
      {:ok, pdf} -> pdf
      {:error, reason} -> raise "could not build pdf: #{reason}"
    end
  end
end
