# Since configuration is shared in umbrella projects, this file
# should only configure the :discotex application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :discotex,
  ecto_repos: [Discotex.Repo]

config :discotex, Discotex.OAuth.GitHub,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
  redirect_uri: System.get_env("GITHUB_REDIRECT_URI"),
  site: "https://api.github.com",
  authorize_url: "https://github.com/login/oauth/authorize",
  token_url: "https://github.com/login/oauth/access_token"

config :discotex, team_app_api_key: System.get_env("TEAM_APP_API_KEY")

import_config "#{Mix.env()}.exs"
