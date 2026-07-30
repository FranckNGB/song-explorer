defmodule SongExplorerWeb.ArtistController do
  @moduledoc """
  Controller REST pour la gestion des artistes.

  Expose l'endpoint `GET /api/artists/:name/albums` permettant de récupérer
  la liste des albums d'un artiste par son nom.

  Le flow est le suivant :
  1. Vérifier si l'artiste est déjà en base de données → retour immédiat
  2. Sinon, interroger l'API Deezer (recherche artiste + récupération albums)
  3. Retourner les albums au format JSON
  4. Sauvegarder l'artiste et ses albums en base de manière asynchrone
  """
  use SongExplorerWeb, :controller
  use OpenApiSpex.ControllerSpecs
  require Logger

  alias SongExplorer.Catalog
  alias SongExplorer.Services.ArtistLookup
  alias SongExplorerWeb.Schemas.{AlbumsResponse, ErrorResponse}

  operation(:albums,
    summary: "Récupérer les albums d'un artiste",
    description:
      "Recherche un artiste par son nom et retourne la liste de ses albums. " <>
        "Si l'artiste est déjà en base, les données sont retournées directement. " <>
        "Sinon, l'API Deezer est interrogée et l'artiste est sauvegardé en base de manière asynchrone.",
    parameters: [
      name: [
        in: :path,
        type: :string,
        description: "Nom de l'artiste",
        required: true,
        example: "drake"
      ]
    ],
    responses: %{
      200 => {"Liste des albums", "application/json", AlbumsResponse},
      404 => {"Artiste non trouvé", "application/json", ErrorResponse},
      503 => {"API Deezer indisponible", "application/json", ErrorResponse}
    }
  )

  @doc """
  Retourne la liste des albums d'un artiste au format JSON.

  ## Paramètres
    - `name` : le nom de l'artiste à rechercher

  ## Réponses
    - `200` : liste des albums `%{albums: [%{title: ..., release_date: ...}]}`
    - `404` : artiste non trouvé sur l'API Deezer
    - `503` : API Deezer indisponible
  """
  def albums(conn, %{"name" => name}) do
    name
    |> ArtistLookup.fetch_albums()
    |> case do
      {:ok, :from_db, albums} ->
        Logger.info("[ARTIST CONTROLLER] Artist #{name} found in database")

        conn
        |> json(%{albums: albums})

      {:ok, :from_deezer, albums, artist_data} ->
        Logger.warning("[ARTIST CONTROLLER] Artist #{name} fetched from Deezer, saving async ...")
        Catalog.save_artist_with_albums_async(artist_data, albums)

        conn
        |> json(%{albums: albums})

      {:error, :not_found} ->
        Logger.error("[ARTIST CONTROLLER] Error Artist #{name} not found on Deezer API")

        conn
        |> put_status(:not_found)
        |> json(%{error: "Artist not found"})

      {:error, reason} ->
        Logger.error("[ARTIST CONTROLLER] Error on Deezer API: #{inspect(reason)}")

        conn
        |> put_status(:service_unavailable)
        |> json(%{error: "Deezer API unavailable"})
    end
  end
end
