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

  @spec render_to_pdf(String.t(), list({atom, any})) :: {:ok, binary()} | {:error, String.t()}
  @doc """
  # TODO
  """
  def render_to_pdf(typst_markup, bindings \\ []) do
    # For now, there's no stdio support or a nice API, so we are going to write
    # the input as a temp file and use a nif to get its output as a Vec<u8>,
    # then bring back to the elixir side as a binary

    # TODO: work on https://github.com/typst/typst/issues/410
    # TODO: add a function that simply given a string, builds the world and
    # everything it needs in order to compile the file

    markup = render_to_string(typst_markup, bindings)

    input_filename = "__typst-input.typst"
    output_filename = "__typst-oupt.typst"

    tmp_dir = System.tmp_dir!()

    input_path = Path.join(tmp_dir, input_filename)
    output_path = Path.join(tmp_dir, output_filename)

    File.write!(input_path, markup)

    result =
      case System.cmd("typst", ["compile", input_path, output_path]) do
        {_, 0} -> {:ok, File.read!(output_path)}
        {error, _} -> {:error, error}
      end

    File.rm!(input_path)
    File.rm!(output_path)

    result
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
