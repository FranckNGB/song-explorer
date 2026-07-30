defmodule SongExplorerWeb.ApiSpec do
  @moduledoc """
  Définition de la spécification OpenAPI pour SongExplorer.
  """
  alias OpenApiSpex.{Info, OpenApi, Paths, Server}
  alias SongExplorerWeb.{Endpoint, Router}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "SongExplorer API",
        version: "1.0.0",
        description:
          "API REST permettant d'explorer le catalogue musical via l'API publique de Deezer."
      },
      security: [%{"api_key" => []}],
      paths: Paths.from_router(Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
    |> then(fn spec ->
      components = %{
        spec.components
        | securitySchemes: %{
            "api_key" => %OpenApiSpex.SecurityScheme{
              type: "apiKey",
              name: "x-api-key",
              in: "header",
              description: "Clé API à passer dans le header x-api-key"
            }
          }
      }

      %{spec | components: components}
    end)
  end
end
