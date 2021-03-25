import Config

# Application configuration
config :gold_rush,
  scheme: "http",
  address: "localhost",
  port: 8000,
  field: %{width: 3500, height: 3500, depth: 10},
  licenses: %{max_licenses: 10, high_watermark: 9, interest_margin: 1, wallet_threshold: 25},
  pools: %{
    explorers: %{size: 50, max_overflow: 0},
    diggers: %{size: 10, max_overflow: 40},
    hackney: %{
      generic: %{timeout: 150000, max_connections: 10},
      licenser: %{timeout: 150000, max_connections: 100},
      accounter: %{timeout: 150000, max_connections: 100},
      explorers: %{timeout: 150000, max_connections: 100},
      diggers: %{timeout: 150000, max_connections: 100}
    }
  }

# Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ],
  truncate: 512

# Console Backend-specific configuration
config :logger, :console,
  format: "[$time] $metadata[$level] $levelpad$message\n",
  metadata: [:pid, :mfa]
