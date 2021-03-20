defmodule GoldRush.Schemas do
  @moduledoc false

  defmodule Area do
    defstruct posX: 0, posY: 0, sizeX: 1, sizeY: 1
  end

  defmodule Balance do
    defstruct balance: 0, wallet: []
  end

  defmodule Dig do
    defstruct licenseID: 0, posX: 0, posY: 0, depth: 1
  end

  defmodule License do
    defstruct id: 0, digAllowed: 0, digUsed: 0
  end

  defmodule Report do
    defstruct amount: 0, area: %Area{}
  end
end
