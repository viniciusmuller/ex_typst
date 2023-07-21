defmodule ExTypst do
  @moduledoc """
  This module provides the core functions for interacting with
  the `typst` markup language compiler.

  Note that when using the formatting directives, they are exactly the same as
  `EEx`, so all of its constructs are supported.

  See [Typst's documentation](https://typst.app/docs) for a quickstart.
  """

  @embedded_fonts [Path.join(:code.priv_dir(:ex_typst), "fonts")]

  @typedoc "Guaranteed to be safe"
  @type safe :: {:safe, iodata()}

  @typedoc "May be safe or unsafe (i.e. it needs to be converted)"
  @type unsafe :: ExTypst.Safe.t()

  @spec render_to_string(String.t(), keyword(unsafe)) :: String.t()
  @doc """
  Formats the given markup template with the given bindings, mostly
  useful for inspecting and debugging.

  ## Examples

      iex> ExTypst.render_to_string("= Hey <%= name %>!", name: "Jude")
      "= Hey \\\"Jude\\\"!"

      iex> ExTypst.render_to_string("= Hey <%= ExTypst.raw(name) %>!", name: "Jude")
      "= Hey Jude!"

  """
  def render_to_string(typst_markup, bindings \\ []) do
    EEx.eval_string(typst_markup, bindings, engine: ExTypst.Engine)
    |> ExTypst.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  @spec raw(iodata() | safe() | nil) :: safe()
  @doc """
  Marks the given markup as raw.

  This means that any Typst markup inside the given string won't be escaped.
  """
  def raw({:safe, value}), do: {:safe, value}
  def raw(nil), do: {:safe, ""}
  def raw(value) when is_binary(value) or is_list(value), do: {:safe, value}

  @doc """
  Escapes any content by wrapping it in a typst string, returning safe iodata.
  """
  @spec escape(unsafe()) :: safe()
  def escape({:safe, _} = safe), do: safe
  def escape(other), do: {:safe, ExTypst.Safe.to_iodata(other)}

  @type pdf_opt :: {:extra_fonts, list(String.t())}

  @spec render_to_pdf(String.t(), keyword(), list(pdf_opt)) ::
          {:ok, binary()} | {:error, String.t()}
  @doc """
  Converts a given piece of typst markup to a PDF binary.

  ## Examples

      iex> {:ok, pdf} = ExTypst.render_to_pdf("= test\\n<%= name %>", name: "John")
      iex> is_binary(pdf)
      true

  """
  def render_to_pdf(typst_markup, bindings \\ [], opts \\ []) do
    extra_fonts = Keyword.get(opts, :extra_fonts, []) ++ @embedded_fonts
    markup = render_to_string(typst_markup, bindings)
    ExTypst.NIF.compile(markup, extra_fonts)
  end

  @spec render_to_pdf!(String.t(), keyword()) :: binary()
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
