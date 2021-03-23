defmodule GoldRush.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Application starting ...\n")
    Logger.info("Options:")
    Logger.info(" Scheme: #{get_param_as_string :scheme}")
    Logger.info(" Address: #{get_param_as_string :address}")
    Logger.info(" Port: #{get_param_as_string :port}")
    Logger.info(" Field: #{get_param_as_string :field}")
    Logger.info(" Licenses: #{get_param_as_string :licenses}")
    Logger.info(" Pools: #{get_param_as_string :pools}\n")

    children = [
      :hackney_pool.child_spec(:generic_pool, [
        timeout: Application.fetch_env!(:gold_rush, :pools).hackney.generic.timeout,
        max_connections: Application.fetch_env!(:gold_rush, :pools).hackney.generic.max_connections
      ]),
      :hackney_pool.child_spec(:licenser_pool, [
        timeout: Application.fetch_env!(:gold_rush, :pools).hackney.licenser.timeout,
        max_connections: Application.fetch_env!(:gold_rush, :pools).hackney.licenser.max_connections
      ]),
      :hackney_pool.child_spec(:accounter_pool, [
        timeout: Application.fetch_env!(:gold_rush, :pools).hackney.accounter.timeout,
        max_connections: Application.fetch_env!(:gold_rush, :pools).hackney.accounter.max_connections
      ]),
      :hackney_pool.child_spec(:explorers_pool, [
        timeout: Application.fetch_env!(:gold_rush, :pools).hackney.explorers.timeout,
        max_connections: Application.fetch_env!(:gold_rush, :pools).hackney.explorers.max_connections
      ]),
      :hackney_pool.child_spec(:diggers_pool, [
        timeout: Application.fetch_env!(:gold_rush, :pools).hackney.diggers.timeout,
        max_connections: Application.fetch_env!(:gold_rush, :pools).hackney.diggers.max_connections
      ]),
      {GoldRush.Accounter, %GoldRush.Schemas.Balance{}},
      {GoldRush.Licenser, []},
      GoldRush.Manager
    ]

    opts = [strategy: :one_for_one, name: GoldRush.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_param_as_string(key) do
    Application.fetch_env!(:gold_rush, key) |> inspect() |> String.replace("%", "")
  end
end
