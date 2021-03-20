import Config

# Application configuration
config :gold_rush,
  scheme: "http",
  address: System.fetch_env!("ADDRESS"),
  port: 8000
