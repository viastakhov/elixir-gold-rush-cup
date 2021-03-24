defmodule GoldRush.Manager do
  use GenServer
  require Logger

  @height Application.fetch_env!(:gold_rush, :field).height
  @width Application.fetch_env!(:gold_rush, :field).width
  @interest_margin Application.fetch_env!(:gold_rush, :licenses).interest_margin

  # Client

  def start_link(_) do
    Logger.info("Manager generic server starting ...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get_license() do
    # The simplest license issue algorithm
    # GoldRush.Licenser.get_license!(:free)

    # More difficult license issue algorithm
    total_amount = GoldRush.Accounter.get_amount()
    if (total_amount > 100) do
      coins_amnt = :rand.uniform(div total_amount * @interest_margin, 100)
      GoldRush.Licenser.get_license!(:paid, coins_amnt)
    else
      GoldRush.Licenser.get_license!(:free)
    end
  end

  def exchange_treasures(treasure_list) do
    #
    Enum.each(treasure_list, fn treasure ->
      Task.start(fn ->
        GoldRush.Accounter.exchange_cash!(treasure)
      end)
    end)
    #
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    wait_api_server()
    run_explorers()
    {:ok, nil}
  end

  defp wait_api_server() do
    case GoldRush.RestClient.health_check() do
      {:ok, _} ->
        Logger.info("REST API Server LIVE!")
        {:ok, :online}
      {_, _} ->
        Logger.debug("REST API Server OFFLINE!")
        :timer.sleep(500)
        wait_api_server()
    end
  end

  defp run_explorers do
    explorers_children = Conqueuer.child_specs(:explorers, GoldRush.Explorers.PoolSupervisor)
    diggers_children = Conqueuer.child_specs(:diggers, GoldRush.Diggers.PoolSupervisor)

    explorers_opts = [strategy: :one_for_one, name: GoldRush.Manager.Explorers.Supervisor]
    Supervisor.start_link(explorers_children, explorers_opts)

    diggers_opts = [strategy: :one_for_one, name: GoldRush.Manager.Diggers.Supervisor]
    Supervisor.start_link(diggers_children, diggers_opts)

    Logger.info("Exploring the field [#{@width} x #{@height}] ...")

    Enum.each(0..@width - 1, fn x ->
      Enum.each(0..@height - 1, fn y ->
        Conqueuer.work(:explorers, {x, y})
      end)
    end)
  end
end
