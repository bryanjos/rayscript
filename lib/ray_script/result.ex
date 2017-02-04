defmodule RayScript.Module do

  @type t :: %__MODULE__{}
  defstruct file: nil, module: nil, export: [], body: []
end
