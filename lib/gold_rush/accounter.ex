defmodule GoldRush.Accounter do
  @moduledoc false

  @max_retries 2

  use Agent
  require Logger

  def start_link(initial_value) do
    Logger.info "[#{inspect self()}] Accounter agent starting ..."
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_ammount do
    Agent.get(__MODULE__, & &1.balance)
  end

  def get_wallet do
    Agent.get(__MODULE__, & &1.wallet)
  end

  def invalidate_balance!, do: do_invalidate_balance!(0)

  defp do_invalidate_balance!(attempt) do
    case GoldRush.RestClient.balance() do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        balance = Poison.decode!(body, as: %GoldRush.Schemas.Balance{})
        Agent.update(__MODULE__, fn _ -> balance end)
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.debug "[#{inspect self()}] Accounter agent << [:#{event}, #{status_code}]:\n#{body}"
        if attempt < @max_retries, do: do_invalidate_balance!(attempt + 1)
    end
  end

  def exchange_cash!(treasure_id), do: do_exchange_cash!(treasure_id, 0)

  defp do_exchange_cash!(treasure_id, attempt) do
    case GoldRush.RestClient.cash(treasure_id) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        wallet = Poison.decode!(body)
        balance = %GoldRush.Schemas.Balance{balance: length(wallet)}
        Agent.update(__MODULE__, fn _ -> balance end)
        {:ok, balance}
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.debug "[#{inspect self()}] Accounter agent << [:#{event}, #{status_code}]:\n#{body}"
        if attempt < @max_retries, do: do_exchange_cash!(treasure_id, attempt + 1)
        {:error, status_code}
    end
  end

  ##
  ##
  ##

  def balance do
    Enum.each(0..100, fn _ ->
      Task.start(fn ->
        GoldRush.RestClient.balance()
        IO.inspect(:hackney_pool.get_stats :generic_pool)
      end)
    end)
  end

  def health_check do
    GoldRush.RestClient.health_check()
  end

  def explore(area) do
    GoldRush.RestClient.explore(area)
  end

  def dig(dig) do
    GoldRush.RestClient.dig(dig)
  end
end
