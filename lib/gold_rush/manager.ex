defmodule GoldRush.Manager do
  use GenServer
  require Logger

  @height Application.fetch_env!(:gold_rush, :field).width
  @width Application.fetch_env!(:gold_rush, :field).height

  # Client

  def start_link(_) do
    Logger.info("Manager generic server starting ...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # def push(pid, element) do
  #   GenServer.cast(pid, {:push, element})
  # end

  # def pop(pid) do
  #   GenServer.call(pid, :pop)
  # end

  # Server (callbacks)

  @impl true
  def init(_) do
    run_explorers()
    {:ok, nil}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

  defp run_explorers do
    explorers_children = Conqueuer.child_specs(:explorers, GoldRush.Explorers.PoolSupervisor)
    diggers_children = Conqueuer.child_specs(:diggers, GoldRush.Diggers.PoolSupervisor)

    explorers_opts = [strategy: :one_for_one, name: GoldRush.Manager.Explorers.Supervisor]
    Supervisor.start_link(explorers_children, explorers_opts)

    diggers_opts = [strategy: :one_for_one, name: GoldRush.Manager.Diggers.Supervisor]
    Supervisor.start_link(diggers_children, diggers_opts)

    Enum.each(0..@width - 1, fn x ->
      Enum.each(0..@height - 1, fn y ->
        Conqueuer.work(:explorers, {x, y})
      end)
    end)
  end
end
