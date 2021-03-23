defmodule GoldRush.RestClient do
  @moduledoc false

  # Handy way to get detailed request logging
  # :hackney_trace.enable(:max, :io)

  defp scheme, do: Application.fetch_env!(:gold_rush, :scheme)
  defp address, do: Application.fetch_env!(:gold_rush, :address)
  defp port, do: Application.fetch_env!(:gold_rush, :port)
  defp base_url, do: "#{scheme()}://#{address()}:#{port()}"

  def balance() do
    %HTTPoison.Request{
      method: :get,
      url: base_url() <> "/balance",
      headers: [
        {"Accept", "application/json"}
      ],
      options: [timeout: 50_000, recv_timeout: 50_000, hackney: [pool: :generic_pool]]
    }
    |> HTTPoison.request
  end

  def cash(treasure) do
    %HTTPoison.Request{
      method: :post,
      url: base_url() <> "/cash",
      body: Poison.encode!(treasure),
      headers: [
        {"Accept", "application/json"},
        {"Content-Type", "application/json"}
      ],
      options: [timeout: 50_000, recv_timeout: 50_000, hackney: [pool: :accounter_pool]]
    }
    |> HTTPoison.request
  end

  def dig(dig = %GoldRush.Schemas.Dig{}) do
    %HTTPoison.Request{
      method: :post,
      url: base_url() <> "/dig",
      body: Poison.encode!(dig),
      headers: [
        {"Accept", "application/json"},
        {"Content-Type", "application/json"}
      ],
      options: [timeout: 50_000, recv_timeout: 50_000, hackney: [pool: :diggers_pool]]
    }
    |> HTTPoison.request
  end

  def explore(area = %GoldRush.Schemas.Area{}) do
    %HTTPoison.Request{
      method: :post,
      url: base_url() <> "/explore",
      body: Poison.encode!(area),
      headers: [
        {"Accept", "application/json"},
        {"Content-Type", "application/json"}
      ],
      options: [timeout: 50_000, recv_timeout: 50_000, hackney: [pool: :explorers_pool]]
    }
    |> HTTPoison.request
  end

  def health_check() do
    %HTTPoison.Request{
      method: :get,
      url: base_url() <> "/health-check",
      headers: [
        {"Accept", "application/json"}
      ],
      options: [timeout: 50_000, recv_timeout: 50_000, hackney: [pool: :generic_pool]]
    }
    |> HTTPoison.request
  end

  def licenses() do
    %HTTPoison.Request{
      method: :get,
      url: base_url() <> "/licenses",
      headers: [
        {"Accept", "application/json"}
      ],
      options: [timeout: 50_000, recv_timeout: 50_000, hackney: [pool: :licenser_pool]]
    }
    |> HTTPoison.request
  end

  def licenses(wallet) do
    %HTTPoison.Request{
      method: :post,
      url: base_url() <> "/licenses",
      body: Poison.encode!(wallet),
      headers: [
        {"Accept", "application/json"},
        {"Content-Type", "application/json"}
      ],
      options: [timeout: 50_000, recv_timeout: 50_000, hackney: [pool: :licenser_pool]]
    }
    |> HTTPoison.request
  end
end
