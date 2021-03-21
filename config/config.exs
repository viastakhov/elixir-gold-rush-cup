import Config

# Application configuration
config :gold_rush,
  scheme: "http",
  address: "localhost",
  port: 8000,
  field: %{width: 350, height: 350, depth: 10},
  pools: %{
    explorers: %{size: 2, max_overflow: 2},
    diggers: %{size: 2, max_overflow: 2}
  }

# Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ],
  truncate: 512

# Console Backend-specific configuration
config :logger, :console,
  format: "[$time] $metadata[$level] $levelpad$message\n",
  metadata: [:pid, :mfa]
