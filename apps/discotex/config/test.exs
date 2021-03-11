# Since configuration is shared in umbrella projects, this file
# should only configure the :discotex application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :discotex, Discotex.Repo,
  username: "postgres",
  password: "postgres",
  database: "discotex_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :discotex, Discotex.TeamApp, adapter: Discotex.TeamApp.RubberDuckClient
