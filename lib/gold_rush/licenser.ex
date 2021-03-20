defmodule GoldRush.Licenser do
  @moduledoc false

  @max_retries 2

  use Agent
  require Logger

  def start_link(initial_value) do
    Logger.info "[#{inspect self()}] Licenser agent starting ..."
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get_licenses do
    Agent.get(__MODULE__, & &1)
  end

  def get_licenses!, do: do_get_licenses!(0)

  defp do_get_licenses!(attempt) do
    case GoldRush.RestClient.licenses() do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: [%GoldRush.Schemas.License{}])}
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.debug "[#{inspect self()}] Licenser agent << [:#{event}, #{status_code}]:\n#{body}"
        if attempt < @max_retries, do: do_get_licenses!(attempt + 1)
        {:error, status_code}
    end
  end

  def invalidate_licenses! do
    case get_licenses!() do
      {:ok, licenses} ->
        Agent.update(__MODULE__, fn _ -> licenses end)
        {:ok, licenses}
      {_, code} -> {:error, code}
    end
  end

  def issue_license!(:free), do: do_issue_license!([], 0)
  def issue_license!(:paid, wallet), do: do_issue_license!(wallet, 0)

  defp do_issue_license!(wallet, attempt) do
    case GoldRush.RestClient.licenses(wallet) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        license = Poison.decode!(body, as: %GoldRush.Schemas.License{})
        invalidate_licenses!()
        {:ok, license}
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.debug "[#{inspect self()}] Licenser agent << [:#{event}, #{status_code}]:\n#{body}"
        if attempt < @max_retries and status_code != 409, do: do_issue_license!(wallet, attempt + 1)
        {:error, status_code}
    end
  end
end
