# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :song_explorer,
  ecto_repos: [SongExplorer.Repo],
  generators: [timestamp_type: :utc_datetime],
  deezer_base_url: System.get_env("DEEZER_BASE_URL") || "https://api.deezer.com",
  se_api_key: System.get_env("SE_API_KEY") || ""

# Configures the endpoint
config :song_explorer, SongExplorerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: SongExplorerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: SongExplorer.PubSub,
  live_view: [signing_salt: "st6LjtcY"]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
