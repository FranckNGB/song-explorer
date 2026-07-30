defmodule SongExplorer.Services.ArtistLookup do
  @moduledoc """
  Service d'orchestration pour la recherche d'artistes.

  Ce module coordonne les appels entre la base de données (Catalog)
  et l'API Deezer (Client) pour récupérer les albums d'un artiste.
  """

  alias SongExplorer.Catalog
  alias SongExplorer.Deezer.Client

  @doc """
  Récupère les albums d'un artiste par son nom.

  Vérifie d'abord en base de données, sinon interroge l'API Deezer.

  ## Paramètres
    - `name` : le nom de l'artiste à rechercher

  ## Retour
    - `{:ok, :from_db, albums}` : albums trouvés en base
    - `{:ok, :from_deezer, albums, artist_data}` : albums récupérés depuis Deezer
    - `{:error, :not_found}` : artiste non trouvé
    - `{:error, reason}` : erreur API Deezer
  """
  def fetch_albums(name) do
    case Catalog.get_artist_by_name(name) do
      %{albums: albums} ->
        formatted = Enum.map(albums, &%{title: &1.title, release_date: &1.release_date})
        {:ok, :from_db, formatted}

      nil ->
        fetch_from_deezer(name)
    end
  end

  defp fetch_from_deezer(name) do
    with {:ok, %{name: artist_name, deezer_id: deezer_id}} <- Client.search_artist(name),
         {:ok, albums} <- Client.get_albums(deezer_id) do
      {:ok, :from_deezer, albums, %{name: artist_name, deezer_id: deezer_id}}
    end
  end
end
