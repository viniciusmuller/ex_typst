defmodule ExTypst.NIF do
  @moduledoc false

  use Rustler, otp_app: :ex_typst, crate: "extypst_nif"

  def compile(_content, _font_paths), do: :erlang.nif_error(:nif_not_loaded)
end
