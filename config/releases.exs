import Config

# Application configuration
config :gold_rush,
  scheme: System.get_env("SCHEME", "http"),
  address: System.get_env("ADDRESS", "localhost"),
  port: System.get_env("PORT", "8000")
