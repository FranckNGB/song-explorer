defmodule SongExplorer.Deezer.Client do
  @moduledoc """
  Client HTTP pour l'API publique de Deezer.

  Ce module fournit les fonctions nécessaires pour interagir avec l'API Deezer :
  - Recherche d'un artiste par nom
  - Récupération de la liste complète des albums d'un artiste (avec gestion de la pagination)

  La base URL de l'API est configurable via la variable d'environnement `DEEZER_BASE_URL`.
  """

  @doc """
  Recherche un artiste par nom et retourne le plus populaire (nb_fan).

  ## Paramètres
    - `name` : le nom de l'artiste à rechercher

  ## Retour
    - `{:ok, %{name: String.t(), deezer_id: integer()}}` en cas de succès
    - `{:error, :not_found}` si aucun artiste n'est trouvé
    - `{:error, reason}` en cas d'erreur HTTP
  """
  def search_artist(name) do
    case Req.get("#{base_url()}/search/artist", params: [q: name]) do
      {:ok, %{status: 200, body: %{"data" => data}}} when data != [] ->
        %{"name" => artist_name, "id" => artist_id} =
          Enum.max_by(data, fn %{"nb_fan" => nb_fan} -> nb_fan end)

        {:ok, %{name: artist_name, deezer_id: artist_id}}

      {:ok, %{status: 200, body: %{"data" => []}}} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Récupère la liste complète des albums d'un artiste via son Deezer ID.

  Gère automatiquement la pagination de l'API Deezer (25 résultats par page).

  ## Paramètres
    - `deezer_id` : l'identifiant Deezer de l'artiste

  ## Retour
    - `{:ok, [%{title: String.t(), release_date: String.t()}]}` en cas de succès
    - `{:error, :not_found}` si aucun album n'est trouvé
    - `{:error, reason}` en cas d'erreur HTTP
  """
  def get_albums(deezer_id) do
    fetch_all_albums("#{base_url()}/artist/#{deezer_id}/albums", [])
  end

  defp fetch_all_albums(url, acc) do
    case Req.get(url) do
      {:ok, %{status: 200, body: %{"data" => data, "next" => next_page_url}}}
      when data != [] ->
        next_page_url
        |> fetch_all_albums(extract_albums(data, acc))

      {:ok, %{status: 200, body: %{"data" => data}}} when data != [] ->
        {:ok, Enum.reverse(extract_albums(data, acc))}

      {:ok, %{status: 200, body: %{"data" => []}}} ->
        if acc == [], do: {:error, :not_found}, else: {:ok, Enum.reverse(acc)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp extract_albums(data, acc) do
    Enum.reduce(data, acc, fn %{"title" => title, "release_date" => release_date}, acc ->
      [%{title: title, release_date: release_date} | acc]
    end)
  end

  defp base_url, do: Application.get_env(:song_explorer, :deezer_base_url)
end
