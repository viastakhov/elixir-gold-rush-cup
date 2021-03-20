defmodule GoldRush.Application do
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.info("Application starting ...")

    children = [
      :hackney_pool.child_spec(:generic_pool, [timeout: 150000, max_connections: 100]),
      {GoldRush.Accounter, %GoldRush.Schemas.Balance{}},
      {GoldRush.Licenser, []}
    ]

    opts = [strategy: :one_for_one, name: GoldRush.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
