defmodule SongExplorerWeb.Schemas do
  @moduledoc """
  Schemas OpenAPI pour la documentation Swagger de l'API SongExplorer.
  """
  alias OpenApiSpex.Schema

  defmodule Album do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "Album",
      description: "Un album musical",
      type: :object,
      properties: %{
        title: %Schema{type: :string, description: "Titre de l'album"},
        release_date: %Schema{type: :string, format: :date, description: "Date de sortie"}
      },
      required: [:title, :release_date],
      example: %{
        "title" => "Scorpion",
        "release_date" => "2018-06-29"
      }
    })
  end

  defmodule AlbumsResponse do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "AlbumsResponse",
      description: "Liste des albums d'un artiste",
      type: :object,
      properties: %{
        albums: %Schema{
          type: :array,
          items: Album,
          description: "Liste des albums"
        }
      },
      required: [:albums],
      example: %{
        "albums" => [
          %{"title" => "Scorpion", "release_date" => "2018-06-29"},
          %{"title" => "Views", "release_date" => "2016-05-06"}
        ]
      }
    })
  end

  defmodule ErrorResponse do
    @moduledoc false
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ErrorResponse",
      description: "Réponse d'erreur",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "Message d'erreur"}
      },
      required: [:error],
      example: %{
        "error" => "Artist not found"
      }
    })
  end
end
