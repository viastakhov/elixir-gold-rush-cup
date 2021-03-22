defmodule GoldRush.Diggers.Worker do
  @moduledoc false

  @max_retries 2
  @max_depth Application.fetch_env!(:gold_rush, :field).depth

  use Conqueuer.Worker
  require Logger

  def perform({amount, pos_x, pos_y}, _state) do
    Logger.debug("Digger worker starting [#{amount}, (#{pos_x}, #{pos_y})] ...")
    #
    dig({pos_x, pos_y, amount, 1})
    #
    Logger.debug("Digger worker [#{pos_x}, #{pos_y}] done.")
  end

  defp dig({_, _, left, _}) when left <= 0, do: :ok
  defp dig({_, _, _, depth}) when depth >= @max_depth, do: :ok

  defp dig({pos_x, pos_y, left, depth}) do
    case GoldRush.Manager.get_license() do
      {:ok, %GoldRush.Schemas.License{id: license_id}} ->
        case do_dig({license_id, pos_x, pos_y, depth}) do
          {:ok, 404} ->
            dig({pos_x, pos_y, left, depth + 1})
          {:ok, 422} ->
            dig({pos_x, pos_y, left, depth + 1})
          {:ok, treasure_list} ->
            #
            Task.start(fn -> GoldRush.Manager.exchange_treasures(treasure_list) end)
            #
            dig({pos_x, pos_y, left - 1, depth + 1})
          {_, _} -> {:error, "dig failure"}
        end
      {_, _} -> {:error, "license failure"}
    end
  end

  def do_dig({license_id, pos_x, pos_y, depth}), do: do_dig!({license_id, pos_x, pos_y, depth}, 0)

  defp do_dig!({license_id, pos_x, pos_y, depth}, attempt) do
    dig_struct = %GoldRush.Schemas.Dig{licenseID: license_id, posX: pos_x, posY: pos_y, depth: depth}
    case GoldRush.RestClient.dig(dig_struct) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        treasure_list = Poison.decode!(body)
        {:ok, treasure_list}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:ok, 404}
      {:ok, %HTTPoison.Response{status_code: 422}} ->
        {:ok, 422}
      {:error, _} ->
        :timer.sleep(1000)
        do_dig!({license_id, pos_x, pos_y, depth}, attempt + 1)
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        if attempt < @max_retries do
          do_dig!({license_id, pos_x, pos_y, depth}, attempt + 1)
        else
          Logger.warn("[:#{event}, #{status_code}]:\n#{body}")
          {:error, status_code}
        end
    end
  end
end
