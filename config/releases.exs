import Config

# Application configuration
config :gold_rush,
  scheme: System.get_env("SCHEME", "http"),
  address: System.get_env("ADDRESS", "localhost"),
  port: System.get_env("PORT", "8000"),
  field: %{width: 3500, height: 3500, depth: 10},
  pools: %{
    explorers: %{size: 10, max_overflow: 0},
    diggers: %{size: 10, max_overflow: 0},
    hackney: %{
      generic: %{timeout: 150000, max_connections: 10},
      licenser: %{timeout: 150000, max_connections: 10},
      accounter: %{timeout: 150000, max_connections: 10},
      explorers: %{timeout: 150000, max_connections: 1000},
      diggers: %{timeout: 150000, max_connections: 100}
    }
  }
