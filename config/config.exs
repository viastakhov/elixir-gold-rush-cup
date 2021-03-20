import Config

# Application configuration
config :gold_rush,
  scheme: "http",
  address: "localhost",
  port: 8000

# Logger general configuration
config :logger,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :debug]
  ],
  truncate: 512

# Console Backend-specific configuration
config :logger, :console,
  format: "\n##### $time $metadata[$level] $levelpad$message\n",
  metadata: [:module, :line, :pid]
