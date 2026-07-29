defmodule SongExplorer.Deezer.Client do
  @base_url "https://api.deezer.com"
  @doc """
  Recherche un artiste par nom et retourne le plus populaire (nb_fan).
  """
  def search_artist(name) do
    case Req.get("#{@base_url}/search/artist", params: [q: name]) do
      {:ok, %{status: 200, body: %{"data" => data}}} when data != [] ->
        artist =
          data
          |> Enum.max_by(fn artist -> artist["nb_fan"] end)

        {:ok, %{name: artist["name"], deezer_id: artist["id"]}}

      {:ok, %{status: 200, body: %{"data" => []}}} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Récupère les albums d'un artiste via son Deezer ID.
  """
  def get_albums(deezer_id) do
    # GET @base_url/artist/{deezer_id}/albums
    # Retourner la liste des albums
    # Format attendu : {:ok, [%{title: ..., release_date: ...}]} ou {:error, reason}

    case Req.get("#{@base_url}/artist/#{deezer_id}/albums") do
      {:ok, %{status: 200, body: %{"data" => data}}} when data != [] ->
        albums =
          Enum.map(data, fn album ->
            %{title: album["title"], release_date: album["release_date"]}
          end)

        {:ok, albums}

      {:ok, %{status: 200, body: %{"data" => []}}} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
