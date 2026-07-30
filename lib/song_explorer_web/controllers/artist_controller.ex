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
  require Logger

  alias SongExplorer.Catalog
  alias SongExplorer.Deezer.Client

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
    |> Catalog.get_artist_by_name()
    |> case do
      %{albums: albums} ->
        formatted_albums =
          Enum.map(albums, fn album ->
            %{title: album.title, release_date: album.release_date}
          end)

        Logger.info(
          "[ARTIST CONTROLLER] The artist #{name} is already present in the database. Fetching from database ..."
        )

        conn
        |> json(%{albums: formatted_albums})

      nil ->
        with {:ok, %{name: artist_name, deezer_id: deezer_id}} <- Client.search_artist(name),
             {:ok, albums} <- Client.get_albums(deezer_id) do
          Logger.warning(
            "[ARTIST CONTROLLER] The artist #{artist_name} doesn't exist in the database . Saving artist data ..."
          )

          Catalog.save_artist_with_albums_async(
            %{name: artist_name, deezer_id: deezer_id},
            albums
          )

          conn
          |> json(%{albums: albums})
        else
          {:error, :not_found} ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Artist not found"})

          {:error, reason} ->
            Logger.error("[ARTIST CONTROLLER] Error on Deezer API with reason #{inspect(reason)}")

            conn
            |> put_status(:service_unavailable)
            |> json(%{error: "Deezer API unavailable"})
        end
    end
  end
end
