defmodule ExTypst.NIF do
  use Rustler, otp_app: :ex_typst, crate: "extypst_nif"

  def compile(_content), do: :erlang.nif_error(:nif_not_loaded)
end
