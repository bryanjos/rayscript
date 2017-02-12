defmodule RayScript.Module do
  @moduledoc """
  Holds module info
  """

  @type t :: %__MODULE__{}
  defstruct file: nil, module: nil, export: [], body: []
end
