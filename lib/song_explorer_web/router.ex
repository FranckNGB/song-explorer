defmodule SongExplorerWeb.Router do
  use SongExplorerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: SongExplorerWeb.ApiSpec
  end

  scope "/api", SongExplorerWeb do
    pipe_through :api

    get "/artists/:name/albums", ArtistController, :albums
  end

  scope "/" do
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end
end
