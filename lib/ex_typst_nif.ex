defmodule ExTypst.NIF do
  use Rustler, otp_app: :ex_typst, crate: "extypst_nif"

  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
