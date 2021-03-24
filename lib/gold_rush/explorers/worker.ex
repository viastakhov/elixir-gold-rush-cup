defmodule GoldRush.Explorers.Worker do
  @moduledoc false

  @max_retries 10

  use Conqueuer.Worker
  require Logger

  def perform({pos_x, pos_y}, _state) do
    Logger.debug("Explorer worker starting [#{pos_x}, #{pos_y}] ...")
    case explore(pos_x, pos_y) do
      {:ok, %GoldRush.Schemas.Report{amount: amount}} ->
        if amount > 0 do
          #
          Conqueuer.work(:diggers, {amount, pos_x, pos_y})
          #
        end
      {_, _} -> :error
    end
    Logger.debug("Explorer worker [#{pos_x}, #{pos_y}] done.")
  end

  defp explore(pos_x, pos_y, size_x \\ 1, size_y \\ 1), do: do_explore(pos_x, pos_y, size_x, size_y, 0)

  defp do_explore(pos_x, pos_y, size_x, size_y, attempt) do
    area = %GoldRush.Schemas.Area{posX: pos_x, posY: pos_y, sizeX: size_x, sizeY: size_y}
    case GoldRush.RestClient.explore(area) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Poison.decode(body, as: %GoldRush.Schemas.Report{})
      {:error, _} ->
        :timer.sleep(1000)
        do_explore(pos_x, pos_y, size_x, size_y, attempt + 1)
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        if attempt < @max_retries do
          do_explore(pos_x, pos_y, size_x, size_y, attempt + 1)
        else
          Logger.warn("[:#{event}, #{status_code}]:\n#{body}")
          {:error, status_code}
        end
    end
  end
end
