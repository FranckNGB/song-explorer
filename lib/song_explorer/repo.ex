defmodule SongExplorer.Repo do
  use Ecto.Repo,
    otp_app: :song_explorer,
    adapter: Ecto.Adapters.Postgres
end
