defprotocol ExTypst.Safe do
  @moduledoc """
  Defines the Typst safe protocol.

  In order to promote Typst safety, ExTypst templates
  do not use `Kernel.to_string/1` to convert data types to
  strings in templates. Instead, ExTypst uses this
  protocol which must be implemented by data structures
  and guarantee that a Typst safe representation is returned.

  Furthermore, this protocol relies on iodata, which provides
  better performance when sending or streaming data to the client.

  Adapted from `Phoenix.HTML.Safe`.
  """

  def to_iodata(data)
end

defimpl ExTypst.Safe, for: Atom do
  def to_iodata(nil), do: ""
  def to_iodata(atom), do: ExTypst.Engine.typst_escape(Atom.to_string(atom))
end

defimpl ExTypst.Safe, for: BitString do
  defdelegate to_iodata(data), to: ExTypst.Engine, as: :typst_escape
end

defimpl ExTypst.Safe, for: Time do
  def to_iodata(time), do: ExTypst.Engine.typst_escape(Time.to_iso8601(time))
end

defimpl ExTypst.Safe, for: Date do
  def to_iodata(date), do: ExTypst.Engine.typst_escape(Date.to_iso8601(date))
end

defimpl ExTypst.Safe, for: NaiveDateTime do
  def to_iodata(dt), do: ExTypst.Engine.typst_escape(NaiveDateTime.to_iso8601(dt))
end

defimpl ExTypst.Safe, for: DateTime do
  def to_iodata(data), do: ExTypst.Engine.typst_escape(DateTime.to_iso8601(data))
end

defimpl ExTypst.Safe, for: Integer do
  def to_iodata(data), do: ExTypst.Engine.typst_escape(Integer.to_string(data))
end

defimpl ExTypst.Safe, for: Float do
  def to_iodata(data), do: ExTypst.Engine.typst_escape(Float.to_string(data))
end

defimpl ExTypst.Safe, for: Tuple do
  def to_iodata({:safe, data}), do: data
  def to_iodata(value), do: raise(Protocol.UndefinedError, protocol: @protocol, value: value)
end

defimpl ExTypst.Safe, for: URI do
  def to_iodata(data), do: ExTypst.Engine.typst_escape(URI.to_string(data))
end
