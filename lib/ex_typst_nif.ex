defmodule ExTypst.NIF do
  @moduledoc false

  use Rustler, otp_app: :ex_typst, crate: "extypst_nif"

  mix_config = Mix.Project.config()
  version = mix_config[:version]
  github_url = mix_config[:package][:links]["GitHub"]

  targets = ~w(
    arm-unknown-linux-gnueabihf
    aarch64-apple-darwin
    aarch64-unknown-linux-gnu
    aarch64-unknown-linux-musl
    riscv64gc-unknown-linux-gnu
    x86_64-apple-darwin
    x86_64-pc-windows-gnu
    x86_64-pc-windows-msvc
    x86_64-unknown-linux-gnu
    x86_64-unknown-linux-musl
  )

  use RustlerPrecompiled,
    otp_app: :typst_rustler,
    crate: "typst_rustler",
    base_url: "#{github_url}/releases/download/v#{version}",
    force_build: System.get_env("EX_TYPST_RUSTLER_BUILD") in ["1", "true"],
    version: version,
    targets: targets

  def compile(_content, _font_paths), do: :erlang.nif_error(:nif_not_loaded)
end
