defmodule GoldRush.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Application starting ...")

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
end
