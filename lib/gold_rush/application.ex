defmodule GoldRush.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Application starting ...")

    children = [
      :hackney_pool.child_spec(:generic_pool, [timeout: 150000, max_connections: 10]),
      :hackney_pool.child_spec(:licenser_pool, [timeout: 150000, max_connections: 10]),
      :hackney_pool.child_spec(:accounter_pool, [timeout: 150000, max_connections: 10]),
      :hackney_pool.child_spec(:explorers_pool, [timeout: 150000, max_connections: 1000]),
      :hackney_pool.child_spec(:diggers_pool, [timeout: 150000, max_connections: 100]),
      {GoldRush.Accounter, %GoldRush.Schemas.Balance{}},
      {GoldRush.Licenser, []},
      GoldRush.Manager
    ]

    opts = [strategy: :one_for_one, name: GoldRush.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
