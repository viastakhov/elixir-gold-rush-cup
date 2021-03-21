defmodule GoldRush.Diggers.PoolSupervisor do
  use Conqueuer.Pool, name: :diggers,
                      worker: GoldRush.Diggers.Worker,
                      size: Application.fetch_env!(:gold_rush, :pools).diggers.size,
                      max_overflow: Application.fetch_env!(:gold_rush, :pools).diggers.max_overflow
end
