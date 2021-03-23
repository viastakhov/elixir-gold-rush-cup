defmodule GoldRush.Licenser do
  @moduledoc false

  @max_retries 10
  @max_licenses Application.fetch_env!(:gold_rush, :licenses).max_licenses
  @high_watermark Application.fetch_env!(:gold_rush, :licenses).high_watermark
  @hight_limit_licenses @max_licenses - (@max_licenses - @high_watermark)

  use Agent
  require Logger

  def start_link(initial_value) do
    Logger.info("Licenser agent starting ...")
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  defp update_licenses(license, licenses_list) do
    %GoldRush.Schemas.License{digAllowed: dig_allowed, digUsed: dig_used, id: id} = license
    cond do
      dig_used == 0 ->
        filtered_license_list = Enum.filter(licenses_list, fn x -> x.id != id end)
        new_license_list = [Map.update(license, :digUsed, 0, fn v -> v + 1 end) | filtered_license_list]
        {{:ok, license}, new_license_list}
      dig_allowed <= dig_used + 1 ->
        new_license_list = Enum.filter(licenses_list, fn x -> x.id != id end)
        {{:ok, license}, new_license_list}
      dig_allowed > dig_used + 1 ->
        filtered_license_list = Enum.filter(licenses_list, fn x -> x.id != id end)
        new_license_list = [Map.update(license, :digUsed, 0, fn v -> v + 1 end) | filtered_license_list]
        {{:ok, license}, new_license_list}
    end
  end

  def get_license!(:free) do
    Agent.get_and_update(__MODULE__, fn licenses ->
      license_cnt = length(licenses)
      if license_cnt < @hight_limit_licenses do
        case issue_license!(:free) do
          {:ok, new_license} ->
            update_licenses(new_license, licenses)
          {_, _} ->
            case get_licenses!() do
              {:ok, lx} ->
                update_licenses(Enum.random(lx), lx)
              {_, } ->
                Logger.error("Getting licenses failue!")
                {:error, licenses}
            end
        end
      else
        update_licenses(Enum.random(licenses), licenses)
      end
    end, :infinity)
  end

  def get_licenses do
    Agent.get(__MODULE__, & &1)
  end

  def get_licenses!, do: do_get_licenses!(0)

  defp do_get_licenses!(attempt) do
    case GoldRush.RestClient.licenses() do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.decode!(body, as: [%GoldRush.Schemas.License{}])}
      {:error, _} ->
        :timer.sleep(1000)
        do_get_licenses!(attempt + 1)
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        if attempt < @max_retries do
          do_get_licenses!(attempt + 1)
        else
          Logger.warn("[:#{event}, #{status_code}]:\n#{body}")
          {:error, status_code}
        end
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
        {:ok, license}
      {event, %HTTPoison.Response{status_code: status_code, body: body}} ->
        if attempt < @max_retries do
          do_issue_license!(wallet, attempt + 1)
        else
          Logger.warn("[:#{event}, #{status_code}]:\n#{body}")
          {:error, status_code}
        end
    end
  end
end
