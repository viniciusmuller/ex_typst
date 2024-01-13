defmodule ExTypst.Engine do
  @moduledoc """
  An EEx.Engine that guarantees typst templates are safe.

  Adapted from `Phoenix.HTML.Engine`.
  """

  @behaviour EEx.Engine

  @anno (if :erlang.system_info(:otp_release) >= ~c"19" do
           [generated: true]
         else
           [line: -1]
         end)

  @doc ~S"""
  Escape a string to be safe for handing off to typst.

  ## Examples

      iex> typst_escape("asfd@asdf") |> to_string()
      "asfd\\@asdf"

      iex> typst_escape("*_`<>@=-+/$\\'\"~-#") |> to_string()
      "\\*\\_\\`\\<\\>\\@\\=\\-\\+\\/\\$\\\\\\'\\\"\\~\\-\\#"
  """
  @spec typst_escape(String.t()) :: iodata()
  def typst_escape(bin) when is_binary(bin) do
    typst_escape(bin, 0, bin, [])
  end

  escapes = [
    # Strong
    {?*, "\\*"},
    # Emphasis
    {?_, "\\_"},
    # Raw
    {?`, "\\`"},
    # Label (right)
    {?<, "\\<"},
    # Label (left)
    {?>, "\\>"},
    # Reference
    {?@, "\\@"},
    # Heading
    {?=, "\\="},
    # Bullet list
    {?-, "\\-"},
    # Numbered list
    {?+, "\\+"},
    # Term list
    {?/, "\\/"},
    # Math
    {?$, "\\$"},
    # Line break
    {?\\, "\\\\"},
    # Smart quote
    {?', "\\'"},
    # Smart quote
    {?", "\\\""},
    # Symbol shorthand
    {?~, "\\~"},
    # Code expression
    {?\#, "\\#"}
  ]

  for {match, insert} <- escapes do
    defp typst_escape(<<unquote(match), rest::bits>>, skip, original, acc) do
      typst_escape(rest, skip + 1, original, [acc | unquote(insert)])
    end
  end

  defp typst_escape(<<_char, rest::bits>>, skip, original, acc) do
    typst_escape(rest, skip, original, acc, 1)
  end

  defp typst_escape(<<>>, _skip, _original, acc) do
    acc
  end

  for {match, insert} <- escapes do
    defp typst_escape(<<unquote(match), rest::bits>>, skip, original, acc, len) do
      part = binary_part(original, skip, len)
      typst_escape(rest, skip + len + 1, original, [acc, part | unquote(insert)])
    end
  end

  defp typst_escape(<<_char, rest::bits>>, skip, original, acc, len) do
    typst_escape(rest, skip, original, acc, len + 1)
  end

  defp typst_escape(<<>>, 0, original, _acc, _len) do
    original
  end

  defp typst_escape(<<>>, skip, original, acc, len) do
    [acc | binary_part(original, skip, len)]
  end

  @doc false
  def init(_opts) do
    %{
      iodata: [],
      dynamic: [],
      vars_count: 0
    }
  end

  @doc false
  def handle_begin(state) do
    %{state | iodata: [], dynamic: []}
  end

  @doc false
  def handle_end(quoted) do
    handle_body(quoted)
  end

  @doc false
  def handle_body(state) do
    %{iodata: iodata, dynamic: dynamic} = state
    safe = {:safe, Enum.reverse(iodata)}
    {:__block__, [], Enum.reverse([safe | dynamic])}
  end

  @doc false
  def handle_text(state, text) do
    handle_text(state, [], text)
  end

  @doc false
  def handle_text(state, _meta, text) do
    %{iodata: iodata} = state
    %{state | iodata: [text | iodata]}
  end

  @doc false
  def handle_expr(state, "=", ast) do
    ast = traverse(ast)
    %{iodata: iodata, dynamic: dynamic, vars_count: vars_count} = state
    var = Macro.var(:"arg#{vars_count}", __MODULE__)
    ast = quote do: unquote(var) = unquote(to_safe(ast))
    %{state | dynamic: [ast | dynamic], iodata: [var | iodata], vars_count: vars_count + 1}
  end

  def handle_expr(state, "", ast) do
    ast = traverse(ast)
    %{dynamic: dynamic} = state
    %{state | dynamic: [ast | dynamic]}
  end

  def handle_expr(state, marker, ast) do
    EEx.Engine.handle_expr(state, marker, ast)
  end

  ## Safe conversion

  defp to_safe(ast), do: to_safe(ast, line_from_expr(ast))

  defp line_from_expr({_, meta, _}) when is_list(meta), do: Keyword.get(meta, :line, 0)
  defp line_from_expr(_), do: 0

  # We can do the work at compile time
  defp to_safe(literal, _line)
       when is_binary(literal) or is_atom(literal) or is_number(literal) do
    literal
    |> ExTypst.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  # We can do the work at runtime
  defp to_safe(literal, line) when is_list(literal) do
    quote line: line, do: ExTypst.Safe.List.to_iodata(unquote(literal))
  end

  # We need to check at runtime and we do so by optimizing common cases.
  defp to_safe(expr, line) do
    # Keep stacktraces for protocol dispatch and coverage
    safe_return = quote line: line, do: data
    bin_return = quote line: line, do: ExTypst.Engine.typst_escape(bin)
    other_return = quote line: line, do: ExTypst.Safe.to_iodata(other)

    # However ignore them for the generated clauses to avoid warnings
    quote @anno do
      case unquote(expr) do
        {:safe, data} -> unquote(safe_return)
        bin when is_binary(bin) -> unquote(bin_return)
        other -> unquote(other_return)
      end
    end
  end

  ## Traversal

  defp traverse(expr) do
    Macro.prewalk(expr, &handle_assign/1)
  end

  defp handle_assign({:@, meta, [{name, _, atom}]}) when is_atom(name) and is_atom(atom) do
    quote line: meta[:line] || 0 do
      ExTypst.Engine.fetch_assign!(var!(assigns), unquote(name))
    end
  end

  defp handle_assign(arg), do: arg

  @doc false
  def fetch_assign!(assigns, key) do
    case Access.fetch(assigns, key) do
      {:ok, val} ->
        val

      :error ->
        raise ArgumentError, """
        assign @#{key} not available in template.

        Please make sure all proper assigns have been set. If this
        is a child template, ensure assigns are given explicitly by
        the parent template as they are not automatically forwarded.

        Available assigns: #{inspect(Enum.map(assigns, &elem(&1, 0)))}
        """
    end
  end
end
