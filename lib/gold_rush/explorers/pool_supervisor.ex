defmodule GoldRush.Explorers.PoolSupervisor do
  use Conqueuer.Pool, name: :explorers,
                      worker: GoldRush.Explorers.Worker,
                      size: Application.fetch_env!(:gold_rush, :pools).explorers.size,
                      max_overflow: Application.fetch_env!(:gold_rush, :pools).explorers.max_overflow
end
