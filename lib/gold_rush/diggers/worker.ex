defmodule GoldRush.Diggers.Worker do
  @moduledoc false

  @max_retries 2

  use Conqueuer.Worker
  require Logger

  def perform({pos_x, pos_y}, _state) do
    Logger.debug("Digger worker starting [#{pos_x}, #{pos_y}] ...")
    # :timer.sleep(100_1000)
    Logger.debug("Digger worker [#{pos_x}, #{pos_y}] done.")
  end
end
