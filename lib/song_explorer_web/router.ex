defmodule SongExplorerWeb.Router do
  use SongExplorerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SongExplorerWeb do
    pipe_through :api
  end
end
