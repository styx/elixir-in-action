defmodule Entity do
  @derive [Access]
  defstruct date: nil, text: nil
  @type t :: %Entity{date: {integer, integer, integer}, text: String.t}
end
