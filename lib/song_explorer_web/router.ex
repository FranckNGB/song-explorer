defmodule SongExplorerWeb.Router do
  @moduledoc false
  use SongExplorerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: SongExplorerWeb.ApiSpec
    plug SongExplorerWeb.Plugs.ApiKeyAuth
  end

  scope "/api", SongExplorerWeb do
    pipe_through :api

    get "/artists/:name/albums", ArtistController, :albums
  end

  pipeline :public do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: SongExplorerWeb.ApiSpec
  end

  scope "/" do
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/openapi",
      persist_authorization: true
  end

  scope "/api" do
    pipe_through :public

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end
end
