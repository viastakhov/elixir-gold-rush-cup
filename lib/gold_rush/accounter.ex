defmodule GoldRush.Accounter do
  @moduledoc false

  @max_retries 100

  use Agent
  require Logger

  def start_link(initial_value) do
    Logger.info("Accounter agent starting ...")
    Task.start(__MODULE__, :balance_monitor, [])
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_amount do
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
      {:error, _} ->
        :timer.sleep(1000)
        do_invalidate_balance!(attempt + 1)
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        if attempt < @max_retries do
          do_invalidate_balance!(attempt + 1)
        else
          Logger.warn("[:#{event}, #{status_code}]:\n#{body}")
          {:error, status_code}
        end
    end
  end

  def exchange_cash!(treasure_id), do: do_exchange_cash!(treasure_id, 0)

  defp do_exchange_cash!(treasure_id, attempt) do
    case GoldRush.RestClient.cash(treasure_id) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        wallet = Poison.decode!(body)
        Agent.update(__MODULE__, fn old_balance ->
          wallet_amount = length(wallet)
          new_balance_balance = wallet_amount + old_balance.balance
          new_balance_wallet = wallet ++ old_balance.wallet
          %GoldRush.Schemas.Balance{
            balance: new_balance_balance,
            wallet: new_balance_wallet
          }
        end)
        {:ok, 200}
      {:error, _} ->
        :timer.sleep(1000)
        do_exchange_cash!(treasure_id, attempt + 1)
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        if attempt < @max_retries do
          do_exchange_cash!(treasure_id, attempt + 1)
        else
          Logger.warn("[:#{event}, #{status_code}]:\n#{body}")
          {:error, status_code}
        end
    end
  end

  def issue_coins(coins_count) do
    Agent.get_and_update(__MODULE__, fn old_balance ->
      new_balance_balance = old_balance.balance - coins_count
      issued_coins = Enum.take(old_balance.wallet, coins_count)
      new_balance_wallet = old_balance.wallet -- issued_coins
      new_balance = %GoldRush.Schemas.Balance{
        balance: new_balance_balance,
        wallet: new_balance_wallet
      }
      {issued_coins, new_balance}
    end, :infinity)
  end

  def balance_monitor do
    :timer.sleep(10_000)
    Logger.info("Current balance: #{get_amount()}")
    balance_monitor()
  end
end
